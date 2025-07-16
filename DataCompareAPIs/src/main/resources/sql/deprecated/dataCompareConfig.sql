CREATE TABLE Data_Compare_Config
(
    config_id BIGINT PRIMARY KEY IDENTITY(1,1),
    table_name VARCHAR(200) UNIQUE,
    source_db VARCHAR(100),
    target_db VARCHAR(100),
    query VARCHAR(MAX),
    query_count VARCHAR(MAX),
    key_column_list VARCHAR(MAX),
    ignore_column_list VARCHAR(MAX),
    compare BIT DEFAULT 0,
    run_now BIT DEFAULT 0,
    created_datetime DATETIME DEFAULT GETDATE(),
    updated_datetime DATETIME DEFAULT GETDATE(),
    created_by VARCHAR(50) DEFAULT '0',
    updated_by VARCHAR(50) DEFAULT '0'
);

-- Add new columns for supporting different target table in same database
ALTER TABLE Data_Compare_Config
ADD target_table_name VARCHAR(200),
    target_query VARCHAR(MAX),
    target_query_count VARCHAR(MAX);
