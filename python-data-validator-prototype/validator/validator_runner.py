import json
import logging
import shutil
from pathlib import Path
from typing import Dict, List, Any
from sqlalchemy import text, create_engine, inspect
from sqlalchemy.exc import SQLAlchemyError

from .dbengine import load_config, create_db_engine, KEY_COLUMN_MAPPING

logger = logging.getLogger(__name__)

class ValidatorRunner:
    """Compare records between RDB and RDB_MODERN databases for matching UID values."""
    
    def __init__(self):
        """Initialize the validator with database connections."""
        self.rdb_engine = None
        self.rdb_modern_engine = None
        self.results_dir = Path(__file__).parent.parent / 'results'
        self.uid_columns = {}  # {table_name: [uid_columns]}
        self.key_columns = {}  # {table_name: [key_columns]}
        # Columns whose value differences should be ignored because
        # there is a known offset between RDB and RDB_MODERN
        self.known_key_column_offsets = set()
    
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

            # Load any configured key columns that have known offsets
            # between RDB and RDB_MODERN so we can ignore their
            # differences in comparison results.
            offsets = config_modern.get('known_key_column_offsets') or []
            self.known_key_column_offsets = {str(col).upper() for col in offsets}
            
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

    def set_key_columns(self, key_columns_map: Dict[str, List[str]]):
        """
        Set the KEY columns for tables.
        
        Args:
            key_columns_map: Dictionary mapping table names to their KEY columns
        """
        self.key_columns = key_columns_map
    
    def _get_mapping_uid(self, engine, mapping_table: str, uid_column: str, key_value: Any) -> Any:
        """
        Query a mapping table to get the UID for a given KEY value.
        
        Args:
            engine: SQLAlchemy engine
            mapping_table: Name of the mapping table (e.g., 'INVESTIGATION', 'D_PATIENT')
            uid_column: Name of the UID column in the mapping table
            key_value: Value of the KEY column to look up
            
        Returns:
            The UID value, or None if not found
        """
        try:
            # Determine the key column name based on mapping table
            if mapping_table == 'INVESTIGATION':
                key_column = 'INVESTIGATION_KEY'
            elif mapping_table == 'D_PATIENT':
                key_column = 'PATIENT_KEY'
            else:
                logger.warning(f"Unknown mapping table: {mapping_table}")
                return None
            
            query = text(f"SELECT [{uid_column}] FROM [{mapping_table}] WHERE [{key_column}] = :key_value")
            with engine.connect() as conn:
                result = conn.execute(query, {"key_value": key_value})
                row = result.fetchone()
                return row[0] if row else None
        except SQLAlchemyError as e:
            logger.error(f"Error querying {mapping_table} for {uid_column} where key={key_value}: {e}")
            return None
    
    def _get_records_by_key(self, engine, table_name: str, key_column: str, key_value: Any) -> List[Dict]:
        """
        Get records from a table for a specific KEY value.
        
        Args:
            engine: SQLAlchemy engine
            table_name: Name of the table
            key_column: Name of the KEY column
            key_value: Value to filter by
            
        Returns:
            List of records as dictionaries
        """
        try:
            query = text(f"SELECT * FROM [{table_name}] WHERE [{key_column}] = :key_value")
            with engine.connect() as conn:
                result = conn.execute(query, {"key_value": key_value})
                rows = result.fetchall()
                
                records = []
                for row in rows:
                    records.append(dict(row._mapping))
                return records
        except SQLAlchemyError as e:
            logger.error(f"Error getting records from {table_name} where {key_column}={key_value}: {e}")
            return []

    def _get_investigation_keys_for_interview(self, engine, d_interview_key: Any) -> List[Any]:
        """Get INVESTIGATION_KEY values from F_INTERVIEW_CASE for a D_INTERVIEW_KEY.

        This is used to bridge from D_INTERVIEW_KEY to INVESTIGATION_KEY
        so that the existing INVESTIGATION_KEY -> CASE_UID mapping logic
        can be reused without changing the report JSON structure.
        """
        try:
            query = text(
                "SELECT DISTINCT [INVESTIGATION_KEY] "
                "FROM [F_INTERVIEW_CASE] "
                "WHERE [D_INTERVIEW_KEY] = :interview_key"
            )
            with engine.connect() as conn:
                result = conn.execute(query, {"interview_key": d_interview_key})
                return [row[0] for row in result.fetchall()]
        except SQLAlchemyError as e:
            logger.error(
                "Error getting INVESTIGATION_KEY from F_INTERVIEW_CASE for D_INTERVIEW_KEY=%s: %s",
                d_interview_key,
                e,
            )
            return []

    def _get_interview_keys_for_case_uid(self, engine, case_uid: Any) -> List[Any]:
        """Get D_INTERVIEW_KEY values for a given CASE_UID via INVESTIGATION.

        This runs the reverse bridge on the RDB side:
        CASE_UID -> INVESTIGATION.INVESTIGATION_KEY -> F_INTERVIEW_CASE.D_INTERVIEW_KEY.
        """
        try:
            query = text(
                "SELECT DISTINCT fic.[D_INTERVIEW_KEY] "
                "FROM [F_INTERVIEW_CASE] fic "
                "JOIN [INVESTIGATION] i ON fic.[INVESTIGATION_KEY] = i.[INVESTIGATION_KEY] "
                "WHERE i.[CASE_UID] = :case_uid"
            )
            with engine.connect() as conn:
                result = conn.execute(query, {"case_uid": case_uid})
                return [row[0] for row in result.fetchall()]
        except SQLAlchemyError as e:
            logger.error(
                "Error getting D_INTERVIEW_KEY from F_INTERVIEW_CASE/INVESTIGATION for CASE_UID=%s: %s",
                case_uid,
                e,
            )
            return []
    
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
        Compare records from both databases to check for differences.
        
        Args:
            rdb_records: Records from RDB
            rdb_modern_records: Records from RDB_MODERN
            
        Returns:
            Comparison result dictionary with summary information
        """
        comparison = {
            'rdb_count': len(rdb_records),
            'rdb_modern_count': len(rdb_modern_records),
            'record_counts_match': len(rdb_records) == len(rdb_modern_records) and len(rdb_records) > 0,
            'column_differences': []
        }
        
        # Compare records only if counts match
        if len(rdb_records) == len(rdb_modern_records):
            # Same number of records - compare column by column
            for i, (rdb_record, rdb_modern_record) in enumerate(zip(rdb_records, rdb_modern_records)):
                discrepancies = self._compare_record_pair(rdb_record, rdb_modern_record)
                
                if discrepancies:
                    comparison['column_differences'].append({
                        'record_index': i,
                        'column_differences': discrepancies
                    })
        
        comparison['has_differences'] = len(comparison['column_differences']) > 0
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
            # Skip columns that are known to have offsets between
            # RDB and RDB_MODERN. We still compare them at the
            # database level, but do not report their discrepancies
            # in the results.
            if str(column).upper() in self.known_key_column_offsets:
                continue

            rdb_value = rdb_record.get(column)
            rdb_modern_value = rdb_modern_record.get(column)
            
            # Convert to string for comparison (handles various types including datetime)
            # and strip whitespace so leading/trailing spaces don't register as a mismatch
            rdb_value_str = str(rdb_value).strip() if rdb_value is not None else None
            rdb_modern_value_str = str(rdb_modern_value).strip() if rdb_modern_value is not None else None
            
            if rdb_value_str != rdb_modern_value_str:
                differences.append({
                    'column': column,
                    'rdb_value': self._serialize_for_json(rdb_value),
                    'rdb_modern_value': self._serialize_for_json(rdb_modern_value)
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
        
    
    def run_validation(self, table_names: List[str], validation_type: str = 'all'):
        """
        Run validation for multiple tables and save results to JSON files.
        
        Args:
            table_names: List of table names to validate
            validation_type: Type of validation - 'uid', 'key', or 'all' (default: 'all')
        """
        if not self.rdb_engine or not self.rdb_modern_engine:
            raise RuntimeError("Database connections not initialized. Call setup_connections() first.")
        
        # Validate validation_type
        if validation_type not in ('uid', 'key', 'all'):
            raise ValueError(f"Invalid validation_type: {validation_type}. Must be 'uid', 'key', or 'all'.")
        
        # Clear and recreate results directory
        if self.results_dir.exists():
            logger.info(f"Clearing existing results directory: {self.results_dir}")
            shutil.rmtree(self.results_dir)
        
        self.results_dir.mkdir(parents=True, exist_ok=True)
        logger.info(f"Results directory: {self.results_dir}")
        logger.info(f"Validation type: {validation_type}")
        
        for table_name in table_names:
            try:
                logger.info(f"Validating table: {table_name}")
                
                validation_results = {}
                
                # Run UID validation if requested
                if validation_type in ('uid', 'all'):
                    logger.info(f"  Running UID validation for {table_name}")
                    uid_result = self.validate_table(table_name)
                    validation_results['uid_validation'] = uid_result
                
                # Run KEY validation if requested
                if validation_type in ('key', 'all'):
                    logger.info(f"  Running KEY validation for {table_name}")
                    key_result = self.validate_table_by_key(table_name)
                    validation_results['key_validation'] = key_result
                
                # Create table-specific directory
                table_dir = self.results_dir / table_name
                table_dir.mkdir(parents=True, exist_ok=True)
                
                # Save results to JSON
                result_file = table_dir / 'validation_results.json'
                with open(result_file, 'w', encoding='utf-8') as f:
                    json.dump(validation_results, f, indent=2, default=str)
                
                logger.info(f"Results saved to {result_file}")
                
            except Exception as e:
                logger.error(f"Error validating table {table_name}: {e}")
                
                # Save error to JSON
                table_dir = self.results_dir / table_name
                table_dir.mkdir(parents=True, exist_ok=True)
                error_file = table_dir / 'validation_results.json'
                
                with open(error_file, 'w', encoding='utf-8') as f:
                    json.dump({'table_name': table_name, 'error': str(e)}, f, indent=2)
    
    def validate_table_by_key(self, table_name: str) -> Dict[str, Any]:
        """
        Validate a table by comparing records across databases using KEY columns and mapping tables.
        
        Args:
            table_name: Name of the table to validate
            
        Returns:
            Dictionary with validation results
        """
        if not self.rdb_engine or not self.rdb_modern_engine:
            raise RuntimeError("Database connections not initialized. Call setup_connections() first.")
        
        if table_name not in self.key_columns:
            logger.warning(f"No KEY columns found for table {table_name}")
            return {'error': f"No KEY columns defined for table {table_name}"}
        
        key_columns = self.key_columns[table_name]
        if not key_columns:
            logger.warning(f"Table {table_name} has no KEY columns")
            return {'error': f"Table {table_name} has no KEY columns"}
        
        table_results = {
            'table_name': table_name,
            'key_columns': key_columns,
            'results_by_key_column': {}
        }

        # Process each KEY column
        for key_column in key_columns:
            # Only process supported KEY columns for core KEY-based comparison
            if key_column not in KEY_COLUMN_MAPPING:
                logger.warning(f"KEY column {key_column} is not supported. Skipping.")
                continue

            mapping_config = KEY_COLUMN_MAPPING[key_column]
            mapping_table = mapping_config['mapping_table']
            mapping_uid_column = mapping_config['mapping_uid_column']

            logger.info(f"Processing table {table_name}, KEY column: {key_column}")

            key_column_results = {
                'key_column': key_column,
                'mapping_table': mapping_table,
                'mapping_uid_column': mapping_uid_column,
                'records_by_mapping_uid': {}
            }

            # Get distinct KEY values from RDB_MODERN
            try:
                query = text(f"SELECT DISTINCT [{key_column}] FROM [{table_name}] ORDER BY [{key_column}]")
                with self.rdb_modern_engine.connect() as conn:
                    result = conn.execute(query)
                    key_values_modern = [row[0] for row in result.fetchall()]
            except SQLAlchemyError as e:
                logger.error(f"Error getting distinct KEY values from {table_name}.{key_column}: {e}")
                key_values_modern = []

            if not key_values_modern:
                logger.warning(f"No KEY values found for {table_name}.{key_column}")
                table_results['results_by_key_column'][key_column] = key_column_results
                continue

            # For each KEY value in RDB_MODERN, get the mapping UID and find corresponding records
            for key_value_modern in key_values_modern:
                # Special handling for D_INTERVIEW_KEY: bridge via
                # F_INTERVIEW_CASE to get INVESTIGATION_KEY and then
                # derive CASE_UID (mapping UID) from INVESTIGATION.
                if key_column == 'D_INTERVIEW_KEY':
                    investigation_keys = self._get_investigation_keys_for_interview(
                        self.rdb_modern_engine,
                        key_value_modern,
                    )

                    if not investigation_keys:
                        logger.warning(
                            "No INVESTIGATION_KEY found in F_INTERVIEW_CASE for D_INTERVIEW_KEY=%s",
                            key_value_modern,
                        )
                        continue

                    # Use each INVESTIGATION_KEY to derive a
                    # CASE_UID mapping UID and then map back to the
                    # corresponding D_INTERVIEW_KEY on the RDB side.
                    for inv_key_modern in investigation_keys:
                        mapping_uid = self._get_mapping_uid(
                            self.rdb_modern_engine,
                            mapping_table,
                            mapping_uid_column,
                            inv_key_modern,
                        )

                        if mapping_uid is None:
                            logger.warning(
                                "Could not find mapping UID (CASE_UID) for INVESTIGATION_KEY=%s (D_INTERVIEW_KEY=%s)",
                                inv_key_modern,
                                key_value_modern,
                            )
                            continue

                        mapping_uid_str = self._serialize_for_json(mapping_uid)

                        if mapping_uid_str not in key_column_results['records_by_mapping_uid']:
                            key_column_results['records_by_mapping_uid'][mapping_uid_str] = {
                                'mapping_uid': mapping_uid_str,
                                'rdb_modern_key_value': None,
                                'rdb_modern_records': [],
                                'rdb_key_value': None,
                                'rdb_records': [],
                                'comparison': None,
                            }

                        # Records from the base table in RDB_MODERN
                        # for this D_INTERVIEW_KEY. Always update both
                        # the stored key value and records so that
                        # rdb_modern_key_value stays in sync with the
                        # D_INTERVIEW_KEY shown in rdb_modern_records,
                        # even when multiple interviews share the same
                        # CASE_UID mapping UID.
                        rdb_modern_records = self._get_records_by_key(
                            self.rdb_modern_engine,
                            table_name,
                            key_column,
                            key_value_modern,
                        )
                        entry = key_column_results['records_by_mapping_uid'][mapping_uid_str]
                        entry['rdb_modern_key_value'] = self._serialize_for_json(key_value_modern)
                        entry['rdb_modern_records'] = self._serialize_for_json(rdb_modern_records)

                        # Find D_INTERVIEW_KEY value(s) in RDB that
                        # correspond to this CASE_UID via
                        # INVESTIGATION and F_INTERVIEW_CASE.
                        interview_keys_rdb = self._get_interview_keys_for_case_uid(
                            self.rdb_engine,
                            mapping_uid,
                        )

                        if not interview_keys_rdb:
                            logger.warning(
                                "Could not find D_INTERVIEW_KEY in RDB for CASE_UID=%s",
                                mapping_uid,
                            )
                            continue

                        # Use the first matching D_INTERVIEW_KEY on the RDB side
                        key_value_rdb = interview_keys_rdb[0]
                        key_column_results['records_by_mapping_uid'][mapping_uid_str]['rdb_key_value'] = self._serialize_for_json(key_value_rdb)

                        # Records from the base table in RDB for the
                        # resolved D_INTERVIEW_KEY
                        rdb_records = self._get_records_by_key(
                            self.rdb_engine,
                            table_name,
                            key_column,
                            key_value_rdb,
                        )
                        key_column_results['records_by_mapping_uid'][mapping_uid_str]['rdb_records'] = self._serialize_for_json(rdb_records)

                        # Compare records
                        comparison = self._compare_records(rdb_records, rdb_modern_records)
                        key_column_results['records_by_mapping_uid'][mapping_uid_str]['comparison'] = self._serialize_for_json(comparison)

                    # Done handling this D_INTERVIEW_KEY value; move
                    # to the next one.
                    continue

                # Default handling for KEY columns with direct
                # mapping-table support (e.g., PATIENT_KEY,
                # INVESTIGATION_KEY).
                mapping_uid = self._get_mapping_uid(
                    self.rdb_modern_engine,
                    mapping_table,
                    mapping_uid_column,
                    key_value_modern,
                )

                if mapping_uid is None:
                    logger.warning(f"Could not find mapping UID for {key_column}={key_value_modern}")
                    continue

                mapping_uid_str = self._serialize_for_json(mapping_uid)

                if mapping_uid_str not in key_column_results['records_by_mapping_uid']:
                    key_column_results['records_by_mapping_uid'][mapping_uid_str] = {
                        'mapping_uid': mapping_uid_str,
                        'rdb_modern_key_value': self._serialize_for_json(key_value_modern),
                        'rdb_modern_records': [],
                        'rdb_key_value': None,
                        'rdb_records': [],
                        'comparison': None
                    }

                # Get records from RDB_MODERN
                rdb_modern_records = self._get_records_by_key(self.rdb_modern_engine, table_name, key_column, key_value_modern)
                key_column_results['records_by_mapping_uid'][mapping_uid_str]['rdb_modern_records'] = self._serialize_for_json(rdb_modern_records)

                # Find corresponding KEY value in RDB using the same mapping UID
                key_value_rdb = self._find_key_value_by_mapping_uid(self.rdb_engine, mapping_table, mapping_uid_column, mapping_uid, key_column)

                if key_value_rdb is None:
                    logger.warning(f"Could not find corresponding KEY value in RDB for {mapping_uid_column}={mapping_uid}")
                    continue

                key_column_results['records_by_mapping_uid'][mapping_uid_str]['rdb_key_value'] = self._serialize_for_json(key_value_rdb)

                # Get records from RDB
                rdb_records = self._get_records_by_key(self.rdb_engine, table_name, key_column, key_value_rdb)
                key_column_results['records_by_mapping_uid'][mapping_uid_str]['rdb_records'] = self._serialize_for_json(rdb_records)

                # Compare records
                comparison = self._compare_records(rdb_records, rdb_modern_records)
                key_column_results['records_by_mapping_uid'][mapping_uid_str]['comparison'] = self._serialize_for_json(comparison)

            table_results['results_by_key_column'][key_column] = key_column_results
        
        return table_results

    def _find_key_value_by_mapping_uid(self, engine, mapping_table: str, uid_column: str, uid_value: Any, key_column: str) -> Any:
        """
        Find the KEY value in a database given a mapping UID.
        
        Args:
            engine: SQLAlchemy engine
            mapping_table: Name of the mapping table
            uid_column: Name of the UID column
            uid_value: Value of the UID to look up
            key_column: Name of the KEY column to retrieve
            
        Returns:
            The KEY value, or None if not found
        """
        try:
            query = text(f"SELECT [{key_column}] FROM [{mapping_table}] WHERE [{uid_column}] = :uid_value")
            with engine.connect() as conn:
                result = conn.execute(query, {"uid_value": uid_value})
                row = result.fetchone()
                return row[0] if row else None
        except SQLAlchemyError as e:
            logger.error(f"Error finding {key_column} in {mapping_table} where {uid_column}={uid_value}: {e}")
            return None
    
    def close_connections(self):
        """Close database connections."""
        if self.rdb_engine:
            self.rdb_engine.dispose()
            logger.info("RDB connection closed")
        
        if self.rdb_modern_engine:
            self.rdb_modern_engine.dispose()
            logger.info("RDB_MODERN connection closed")
