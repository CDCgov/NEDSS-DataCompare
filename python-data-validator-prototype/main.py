import logging
import argparse
from pathlib import Path
from validator.validator_setup import ValidatorSetup
from validator.validator_runner import ValidatorRunner

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def load_tables_from_file(file_path: str) -> list:
    """
    Load table names from a text file (one table per line).
    
    Args:
        file_path: Path to the text file with table names
        
    Returns:
        List of table names
    """
    try:
        path = Path(file_path)
        if not path.exists():
            logger.error(f"Table file not found: {file_path}")
            return []
        
        with open(path, 'r', encoding='utf-8') as f:
            tables = [line.strip() for line in f if line.strip()]
        
        logger.info(f"Loaded {len(tables)} table names from {file_path}")
        return tables
    except Exception as e:
        logger.error(f"Error loading table file: {e}")
        return []


def main():
    """Main entry point."""
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description='Data Validator for SQL Server tables')
    parser.add_argument('--target-tables', help='Path to text file with list of tables (one per line)', type=str)
    parser.add_argument('--validation-type', help='Type of validation to run: uid, key, or all (default: all)', 
                        type=str, choices=['uid', 'key', 'all'], default='all')
    args = parser.parse_args()
    
    try:
        # Initialize and load ValidationSetup
        logger.info("Initializing ValidationSetup...")
        validator = ValidatorSetup()
        
        if not validator.load_uid_columns_from_csv():
            logger.error("Failed to load UID columns CSV")
            return
        
        if not validator.load_key_columns_from_csv():
            logger.error("Failed to load KEY columns CSV")
            return
        
        # Print validator summary
        summary = validator.get_summary()
        logger.info(f"Validator Summary: {summary}")
        
        # Determine tables to validate
        if args.target_tables:
            logger.info(f"Validating tables from file: {args.target_tables}")
            table_list = load_tables_from_file(args.target_tables)
            # Validate the provided tables exist in our loaded data
            validation_result = validator.validate_input_table_list(table_list)
        else:
            logger.info("No target tables specified. Using tables from CSV based on validation type.")
            
            # Get tables based on validation type
            if args.validation_type == 'uid':
                table_list = validator.get_all_tables_with_uid_columns()
            elif args.validation_type == 'key':
                table_list = list(validator.table_key_consolidated.keys())
            else:  # 'all'
                # Get union of both UID and KEY tables
                uid_tables = set(validator.get_all_tables_with_uid_columns())
                key_tables = set(validator.table_key_consolidated.keys())
                table_list = sorted(list(uid_tables | key_tables))
            
            # Create validation result for selected tables
            validation_result = {
                'total_requested': len(table_list),
                'found_count': len(table_list),
                'missing_count': 0,
                'found_tables': [
                    {
                        'table_name': t,
                        'uid_columns': validator.get_uid_columns_for_table(t),
                        'key_columns': validator.get_key_columns_for_table(t),
                        'column_count': len(validator.get_uid_columns_for_table(t)) + len(validator.get_key_columns_for_table(t))
                    }
                    for t in table_list
                ],
                'missing_tables': []
            }
        
        if table_list:
            logger.info(f"Table Validation Results:")
            logger.info(f"  Total Requested: {validation_result['total_requested']}")
            logger.info(f"  Found: {validation_result['found_count']}")
            logger.info(f"  Missing: {validation_result['missing_count']}")
            
            if validation_result['missing_tables']:
                logger.warning(f"  Missing tables: {validation_result['missing_tables']}")
            
            # Log details for found tables
            for table_info in validation_result['found_tables']:
                logger.info(f"    {table_info['table_name']}: {table_info['column_count']} identifier columns")
            
            # Run record validation if tables were found
            if validation_result['found_count'] > 0:
                logger.info("\n" + "="*80)
                logger.info("Starting record-level validation across RDB and RDB_MODERN databases...")
                logger.info("="*80 + "\n")
                    
                try:
                    # Initialize record validator
                    record_validator = ValidatorRunner()
                    
                    # Setup database connections
                    logger.info("Setting up database connections...")
                    record_validator.setup_connections()
                    
                    # Get the UID columns map for validated tables
                    uid_columns_map = {}
                    for table_info in validation_result['found_tables']:
                        table_name = table_info['table_name']
                        uid_columns_map[table_name] = validator.get_uid_columns_for_table(table_name)

                    # Get the KEY columns map for validated tables
                    key_columns_map = {}
                    for table_info in validation_result['found_tables']:
                        table_name = table_info['table_name']
                        key_columns_map[table_name] = validator.get_key_columns_for_table(table_name)
                    
                    logger.info(f"UID columns map prepared for {len(uid_columns_map)} tables")
                    record_validator.set_uid_columns(uid_columns_map)
                    record_validator.set_key_columns(key_columns_map)
                    
                    # Run validation
                    found_table_names = [t['table_name'] for t in validation_result['found_tables']]
                    logger.info(f"Running record validation for {len(found_table_names)} tables...")
                    record_validator.run_validation(found_table_names, validation_type=args.validation_type)
                    
                    # Close connections
                    record_validator.close_connections()
                    logger.info("\nRecord validation completed successfully!")
                    logger.info(f"Results saved to: {record_validator.results_dir}")
                    
                except Exception as e:
                    logger.error(f"Error during record validation: {e}")
                    raise
        
    except Exception as e:
        logger.error(f"Error in main: {e}")
        raise


if __name__ == "__main__":
    main()
