import json
import logging
from pathlib import Path
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError

logger = logging.getLogger(__name__)


def load_config(config_file='db-config.json'):
    """Load database configuration from JSON file."""
    config_path = Path(__file__).parent.parent / config_file
    
    if not config_path.exists():
        raise FileNotFoundError(f"Configuration file not found: {config_path}")
    
    with open(config_path, 'r') as f:
        config = json.load(f)
    
    logger.info(f"Configuration loaded from {config_path}")
    return config


def build_connection_string(config):
    """Build SQLAlchemy connection string from config."""
    db_config = config['database']
    connection_options = config.get('connection_options', {})
    
    # Build ODBC connection string
    odbc_params = [
        f"Driver={{{db_config['driver']}}}",
        f"Server={db_config['server']},{db_config['port']}",
        f"Database={db_config['database']}",
        f"UID={db_config['username']}",
        f"PWD={db_config['password']}"
    ]
    
    # Add connection options
    for key, value in connection_options.items():
        odbc_params.append(f"{key}={value}")
    
    odbc_string = ";".join(odbc_params)
    
    # SQLAlchemy connection string
    connection_string = f"mssql+pyodbc:///?odbc_connect={odbc_string}"
    
    return connection_string


def create_db_engine(config):
    """Create SQLAlchemy engine with configuration."""
    try:
        connection_string = build_connection_string(config)
        engine = create_engine(
            connection_string,
            pool_size=config['sqlalchemy']['pool_size'],
            max_overflow=config['sqlalchemy']['max_overflow'],
            pool_recycle=config['sqlalchemy']['pool_recycle'],
            pool_pre_ping=config['sqlalchemy']['pool_pre_ping'],
            echo=config['sqlalchemy']['echo']
        )
        logger.info("Database engine created successfully")
        return engine
    except Exception as e:
        logger.error(f"Failed to create database engine: {e}")
        raise


def test_connection(engine):
    """Test database connection."""
    try:
        with engine.connect() as conn:
            result = conn.execute(text("SELECT 1 as connection_test"))
            row = result.fetchone()
            logger.info(f"Connection successful: {row}")
            return True
    except SQLAlchemyError as e:
        logger.error(f"Connection failed: {e}")
        return False


# Mapping configuration for KEY columns to their respective mapping tables
KEY_COLUMN_MAPPING = {
    'INVESTIGATION_KEY': {
        'mapping_table': 'INVESTIGATION',
        'mapping_uid_column': 'CASE_UID'
    },
    'PATIENT_KEY': {
        'mapping_table': 'D_PATIENT',
        'mapping_uid_column': 'PATIENT_UID'
    }
}
