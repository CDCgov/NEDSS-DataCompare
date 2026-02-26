import csv
import logging
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Tuple

logger = logging.getLogger(__name__)


class TableUIDValidator:
    """Validator for table UID columns across RDB and RDB_MODERN databases."""
    
    def __init__(self):
        """Initialize the validator with empty data structures."""
        # Structure: {table_name: {database: [uid_columns]}}
        self.table_uid_map = defaultdict(lambda: defaultdict(list))
        
        # Structure: {table_name: [uid_columns]} - consolidated view
        self.table_uid_consolidated = defaultdict(list)
        
        # Raw data from CSV for reference
        self.uid_columns_data = []
    
    def load_uid_columns_from_csv(self, csv_file: str = 'matching_rdb_tables-uid-columns.csv') -> bool:
        """
        Load UID column mappings from CSV file.
        
        Expected CSV columns: TABLE_NAME, COLUMN_NAME
        
        Args:
            csv_file: Path to the CSV file (relative to project root)
            
        Returns:
            True if successful, False otherwise
        """
        try:
            csv_path = Path(__file__).parent.parent / csv_file
            
            if not csv_path.exists():
                logger.error(f"CSV file not found: {csv_path}")
                return False
            
            self.uid_columns_data = []
            self.table_uid_map.clear()
            self.table_uid_consolidated.clear()
            
            with open(csv_path, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                
                for row in reader:
                    table_name = row['TABLE_NAME'].strip()
                    column_name = row['COLUMN_NAME'].strip()
                    
                    # Store raw data
                    self.uid_columns_data.append({
                        'table_name': table_name,
                        'column_name': column_name
                    })
                    
                    # Build organized map
                    self.table_uid_map[table_name]['data'].append(column_name)
                    
                    # Build consolidated map (unique columns per table)
                    if column_name not in self.table_uid_consolidated[table_name]:
                        self.table_uid_consolidated[table_name].append(column_name)
            
            logger.info(f"Loaded {len(self.uid_columns_data)} UID column records from {csv_path}")
            logger.info(f"Found {len(self.table_uid_consolidated)} tables with UID columns")
            return True
            
        except Exception as e:
            logger.error(f"Error loading CSV file: {e}")
            return False
    
    def get_uid_columns_for_table(self, table_name: str) -> List[str]:
        """
        Get the list of UID column names for a specific table.
        
        Args:
            table_name: Name of the table
            
        Returns:
            List of UID column names, empty list if table not found
        """
        return self.table_uid_consolidated.get(table_name, [])
    
    def get_table_uid_columns_by_database(self, table_name: str) -> Dict[str, List[str]]:
        """
        Get UID columns for a table (deprecated - kept for compatibility).
        
        Args:
            table_name: Name of the table
            
        Returns:
            Dict with column list
        """
        if table_name not in self.table_uid_map:
            return {}
        
        return {'columns': self.table_uid_map[table_name]['data']}
    
    def get_all_tables_with_uid_columns(self) -> List[str]:
        """
        Get list of all tables that have UID columns.
        
        Returns:
            Sorted list of table names
        """
        return sorted(list(self.table_uid_consolidated.keys()))
    
    def get_table_uid_columns_detailed(self, table_name: str) -> Dict[str, any]:
        """
        Get detailed information about UID columns in a table.
        
        Args:
            table_name: Name of the table
            
        Returns:
            Dictionary with detailed column information
        """
        if table_name not in self.table_uid_map:
            return {}
        
        return dict(self.table_uid_map[table_name])
    
    def compare_tables_uid_columns(self, table_name: str) -> Dict[str, any]:
        """
        Get UID column information for a table.
        
        Args:
            table_name: Name of the table
            
        Returns:
            Dictionary with column information
        """
        if table_name not in self.table_uid_map:
            return {'exists': False}
        
        columns = self.table_uid_map[table_name]['data']
        
        return {
            'exists': True,
            'table_name': table_name,
            'uid_columns': sorted(columns),
            'column_count': len(columns)
        }
    
    def validate_input_table_list(self, table_list: List[str]) -> Dict[str, any]:
        """
        Validate a list of table names against loaded UID column data.
        
        Args:
            table_list: List of table names to validate
            
        Returns:
            Dictionary with validation results
            
        Raises:
            ValueError: If any tables in the list are not found in loaded data
        """
        # Create a case-insensitive lookup map
        case_insensitive_map = {name.upper(): name for name in self.table_uid_consolidated.keys()}
        print(f"Case-insensitive map keys: {list(case_insensitive_map.keys())}")
        
        found_tables = []
        missing_tables = []
        
        for table_name in table_list:
            table_upper = table_name.upper().strip()
            if table_upper in case_insensitive_map:
                actual_name = case_insensitive_map[table_upper]
                found_tables.append({
                    'table_name': actual_name,
                    'uid_columns': self.get_uid_columns_for_table(actual_name),
                    'column_count': len(self.get_uid_columns_for_table(actual_name))
                })
            else:
                missing_tables.append(table_name)
        
        # Raise error if any tables are missing
        if missing_tables:
            error_msg = f"The following {len(missing_tables)} table(s) were not found in loaded UID column data: {', '.join(missing_tables)}"
            logger.error(error_msg)
            raise ValueError(error_msg)
        
        return {
            'total_requested': len(table_list),
            'found_count': len(found_tables),
            'missing_count': 0,
            'found_tables': found_tables,
            'missing_tables': []
        }
    
    def get_summary(self) -> Dict[str, any]:
        """
        Get summary statistics about loaded UID columns.
        
        Returns:
            Dictionary with summary information
        """
        total_columns = sum(len(cols) for cols in self.table_uid_consolidated.values())
        
        return {
            'total_uid_column_records': len(self.uid_columns_data),
            'total_tables_with_uid_columns': len(self.table_uid_consolidated),
            'total_unique_uid_columns': total_columns
        }


def main():
    """Example usage of the TableUIDValidator."""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )
    
    # Initialize validator
    validator = TableUIDValidator()
    
    # Load CSV
    if validator.load_uid_columns_from_csv():
        # Print summary
        summary = validator.get_summary()
        print("\n=== Summary ===")
        for key, value in summary.items():
            print(f"{key}: {value}")
        
        # Example: Get UID columns for a specific table
        print("\n=== Example Tables ===")
        all_tables = validator.get_all_tables_with_uid_columns()
        if all_tables:
            example_table = all_tables[0]
            print(f"\nTable: {example_table}")
            print(f"UID Columns: {validator.get_uid_columns_for_table(example_table)}")
            
            info = validator.compare_tables_uid_columns(example_table)
            print(f"Info: {info}")


if __name__ == "__main__":
    main()
