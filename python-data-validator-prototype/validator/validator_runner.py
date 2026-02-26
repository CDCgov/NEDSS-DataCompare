import json
import logging
from pathlib import Path
from typing import Dict, List, Any
from sqlalchemy import text, create_engine, inspect
from sqlalchemy.exc import SQLAlchemyError

from .dbengine import load_config, create_db_engine

logger = logging.getLogger(__name__)


class TableRecordValidator:
    """Compare records between RDB and RDB_MODERN databases for matching UID values."""
    
    def __init__(self):
        """Initialize the validator with database connections."""
        self.rdb_engine = None
        self.rdb_modern_engine = None
        self.results_dir = Path(__file__).parent.parent / 'results'
        self.uid_columns = {}  # {table_name: [uid_columns]}
    
    def setup_connections(self, rdb_config_path: str = 'db-config.json', 
                         rdb_modern_config_path: str = 'db-config.json'):
        """
        Setup connections to both RDB and RDB_MODERN databases.
        
        Args:
            rdb_config_path: Path to RDB config (change database to 'RDB')
            rdb_modern_config_path: Path to RDB_MODERN config
        """
        try:
            # Load RDB_MODERN config
            config_modern = load_config(rdb_modern_config_path)
            self.rdb_modern_engine = create_db_engine(config_modern)
            logger.info("Connected to RDB_MODERN database")
            
            # Load RDB config and switch database name
            config_rdb = load_config(rdb_config_path)
            config_rdb['database']['database'] = 'RDB'
            self.rdb_engine = create_db_engine(config_rdb)
            logger.info("Connected to RDB database")
            
        except Exception as e:
            logger.error(f"Failed to setup database connections: {e}")
            raise
    
    def set_uid_columns(self, uid_columns_map: Dict[str, List[str]]):
        """
        Set the UID columns for tables.
        
        Args:
            uid_columns_map: Dictionary mapping table names to their UID columns
        """
        self.uid_columns = uid_columns_map
    
    def _get_distinct_uid_values(self, engine, table_name: str, uid_column: str) -> List[Any]:
        """
        Get distinct values from a UID column in a table.
        
        Args:
            engine: SQLAlchemy engine
            table_name: Name of the table
            uid_column: Name of the UID column
            
        Returns:
            List of distinct UID values
        """
        try:
            query = text(f"SELECT DISTINCT [{uid_column}] FROM [{table_name}] ORDER BY [{uid_column}]")
            with engine.connect() as conn:
                result = conn.execute(query)
                return [row[0] for row in result.fetchall()]
        except SQLAlchemyError as e:
            logger.error(f"Error getting distinct UID values from {table_name}.{uid_column}: {e}")
            return []
    
    def _get_records_by_uid(self, engine, table_name: str, uid_column: str, uid_value: Any) -> List[Dict]:
        """
        Get records from a table for a specific UID value.
        
        Args:
            engine: SQLAlchemy engine
            table_name: Name of the table
            uid_column: Name of the UID column
            uid_value: Value to filter by
            
        Returns:
            List of records as dictionaries
        """
        try:
            query = text(f"SELECT * FROM [{table_name}] WHERE [{uid_column}] = :uid_value")
            with engine.connect() as conn:
                result = conn.execute(query, {"uid_value": uid_value})
                rows = result.fetchall()
                
                # Convert rows to dictionaries
                records = []
                for row in rows:
                    records.append(dict(row._mapping))
                return records
        except SQLAlchemyError as e:
            logger.error(f"Error getting records from {table_name} where {uid_column}={uid_value}: {e}")
            return []
    
    def _compare_records(self, rdb_records: List[Dict], rdb_modern_records: List[Dict]) -> Dict[str, Any]:
        """
        Compare records from both databases, column by column.
        
        Args:
            rdb_records: Records from RDB
            rdb_modern_records: Records from RDB_MODERN
            
        Returns:
            Comparison result dictionary with only discrepant records
        """
        comparison = {
            'rdb_count': len(rdb_records),
            'rdb_modern_count': len(rdb_modern_records),
            'match': len(rdb_records) == len(rdb_modern_records) and len(rdb_records) > 0,
            'discrepant_records': []
        }
        
        # Create a map of RDB_MODERN records by converting to comparable format
        # Use a combination of all columns as a unique key for matching
        rdb_modern_map = {}
        for record in rdb_modern_records:
            rdb_modern_map[id(record)] = record
        
        # If record counts differ, note it
        if len(rdb_records) != len(rdb_modern_records):
            comparison['record_count_mismatch'] = {
                'rdb_count': len(rdb_records),
                'rdb_modern_count': len(rdb_modern_records)
            }
        
        # Compare records
        if len(rdb_records) != len(rdb_modern_records):
            # Different number of records - compare what we can
            for i, rdb_record in enumerate(rdb_records):
                if i < len(rdb_modern_records):
                    rdb_modern_record = rdb_modern_records[i]
                    discrepancies = self._compare_record_pair(rdb_record, rdb_modern_record)
                    
                    if discrepancies:
                        comparison['discrepant_records'].append({
                            'record_index': i,
                            'rdb_record': rdb_record,
                            'rdb_modern_record': rdb_modern_record,
                            'column_differences': discrepancies
                        })
                else:
                    # More records in RDB than RDB_MODERN
                    comparison['discrepant_records'].append({
                        'record_index': i,
                        'type': 'record_in_rdb_only',
                        'rdb_record': rdb_record
                    })
            
            # Check for extra records in RDB_MODERN
            for i in range(len(rdb_records), len(rdb_modern_records)):
                comparison['discrepant_records'].append({
                    'record_index': i,
                    'type': 'record_in_rdb_modern_only',
                    'rdb_modern_record': rdb_modern_records[i]
                })
        else:
            # Same number of records - compare column by column
            for i, (rdb_record, rdb_modern_record) in enumerate(zip(rdb_records, rdb_modern_records)):
                discrepancies = self._compare_record_pair(rdb_record, rdb_modern_record)
                
                if discrepancies:
                    comparison['discrepant_records'].append({
                        'record_index': i,
                        'rdb_record': rdb_record,
                        'rdb_modern_record': rdb_modern_record,
                        'column_differences': discrepancies
                    })
        
        comparison['discrepant_count'] = len(comparison['discrepant_records'])
        comparison['has_differences'] = comparison['discrepant_count'] > 0
        return comparison
    
    def _compare_record_pair(self, rdb_record: Dict, rdb_modern_record: Dict) -> List[Dict]:
        """
        Compare two individual records column by column.
        
        Args:
            rdb_record: Record from RDB
            rdb_modern_record: Record from RDB_MODERN
            
        Returns:
            List of column differences
        """
        differences = []
        
        # Get all columns from both records
        all_columns = set(rdb_record.keys()) | set(rdb_modern_record.keys())
        
        for column in sorted(all_columns):
            rdb_value = rdb_record.get(column)
            rdb_modern_value = rdb_modern_record.get(column)
            
            # Convert to string for comparison (handles various types including datetime)
            rdb_value_str = str(rdb_value) if rdb_value is not None else None
            rdb_modern_value_str = str(rdb_modern_value) if rdb_modern_value is not None else None
            
            if rdb_value_str != rdb_modern_value_str:
                differences.append({
                    'column': column,
                    'rdb_value': self._serialize_for_json(rdb_value),
                    'rdb_modern_value': self._serialize_for_json(rdb_modern_value),
                    'rdb_type': type(rdb_value).__name__ if rdb_value is not None else 'NoneType',
                    'rdb_modern_type': type(rdb_modern_value).__name__ if rdb_modern_value is not None else 'NoneType'
                })
        
        return differences
    
    def _serialize_for_json(self, obj: Any) -> Any:
        """Convert non-JSON-serializable objects to JSON-serializable format."""
        if isinstance(obj, (str, int, float, bool, type(None))):
            return obj
        elif isinstance(obj, dict):
            return {k: self._serialize_for_json(v) for k, v in obj.items()}
        elif isinstance(obj, (list, tuple)):
            return [self._serialize_for_json(item) for item in obj]
        else:
            return str(obj)
    
    def validate_table(self, table_name: str) -> Dict[str, Any]:
        """
        Validate a table by comparing records across databases for matching UID values.
        
        Args:
            table_name: Name of the table to validate
            
        Returns:
            Dictionary with validation results
        """
        if not self.rdb_engine or not self.rdb_modern_engine:
            raise RuntimeError("Database connections not initialized. Call setup_connections() first.")
        
        if table_name not in self.uid_columns:
            logger.warning(f"No UID columns found for table {table_name}")
            return {'error': f"No UID columns defined for table {table_name}"}
        
        uid_columns = self.uid_columns[table_name]
        if not uid_columns:
            logger.warning(f"Table {table_name} has no UID columns")
            return {'error': f"Table {table_name} has no UID columns"}
        
        table_results = {
            'table_name': table_name,
            'uid_columns': uid_columns,
            'results_by_uid_column': {}
        }
        
        # For each UID column, compare records
        for uid_column in uid_columns:
            logger.info(f"Processing table {table_name}, UID column: {uid_column}")
            
            uid_column_results = {
                'uid_column': uid_column,
                'uid_values': []
            }
            
            # Get distinct UID values from RDB_MODERN
            uid_values = self._get_distinct_uid_values(self.rdb_modern_engine, table_name, uid_column)
            
            if not uid_values:
                logger.warning(f"No UID values found for {table_name}.{uid_column}")
                table_results['results_by_uid_column'][uid_column] = uid_column_results
                continue
            
            # For each UID value, get records from both databases and compare
            for uid_value in uid_values:
                rdb_records = self._get_records_by_uid(self.rdb_engine, table_name, uid_column, uid_value)
                rdb_modern_records = self._get_records_by_uid(self.rdb_modern_engine, table_name, uid_column, uid_value)
                
                comparison = self._compare_records(rdb_records, rdb_modern_records)
                
                uid_column_results['uid_values'].append({
                    'uid_value': self._serialize_for_json(uid_value),
                    'comparison': self._serialize_for_json(comparison)
                })
            
            table_results['results_by_uid_column'][uid_column] = uid_column_results
        
        return table_results
    
    def run_validation(self, table_names: List[str]):
        """
        Run validation for multiple tables and save results to JSON files.
        
        Args:
            table_names: List of table names to validate
        """
        if not self.rdb_engine or not self.rdb_modern_engine:
            raise RuntimeError("Database connections not initialized. Call setup_connections() first.")
        
        # Create results directory
        self.results_dir.mkdir(parents=True, exist_ok=True)
        logger.info(f"Results directory: {self.results_dir}")
        
        for table_name in table_names:
            try:
                logger.info(f"Validating table: {table_name}")
                
                # Validate table
                validation_result = self.validate_table(table_name)
                
                # Create table-specific directory
                table_dir = self.results_dir / table_name
                table_dir.mkdir(parents=True, exist_ok=True)
                
                # Save results to JSON
                result_file = table_dir / 'validation_results.json'
                with open(result_file, 'w', encoding='utf-8') as f:
                    json.dump(validation_result, f, indent=2, default=str)
                
                logger.info(f"Results saved to {result_file}")
                
            except Exception as e:
                logger.error(f"Error validating table {table_name}: {e}")
                
                # Save error to JSON
                table_dir = self.results_dir / table_name
                table_dir.mkdir(parents=True, exist_ok=True)
                error_file = table_dir / 'validation_results.json'
                
                with open(error_file, 'w', encoding='utf-8') as f:
                    json.dump({'table_name': table_name, 'error': str(e)}, f, indent=2)
    
    def close_connections(self):
        """Close database connections."""
        if self.rdb_engine:
            self.rdb_engine.dispose()
            logger.info("RDB connection closed")
        
        if self.rdb_modern_engine:
            self.rdb_modern_engine.dispose()
            logger.info("RDB_MODERN connection closed")
