CREATE TABLE Data_Compare_Config
(
    table_name       VARCHAR(200) PRIMARY KEY,
    source_db        VARCHAR(100),
    target_db        VARCHAR(100),
    rdb_sql_query        VARCHAR(MAX),
    rdb_sql_count_query        VARCHAR(MAX),
    rdb_modern_sql_query VARCHAR(MAX),
    rdb_modern_sql_count_query VARCHAR(MAX),
    key_column VARCHAR(200),
    ignore_columns VARCHAR(MAX),
    compare          BIT,
    file_type        VARCHAR(20),
    storage_location VARCHAR(200),
    created_datetime DATETIME DEFAULT GETDATE(),
    updated_datetime DATETIME DEFAULT GETDATE(),
    created_by       VARCHAR(50),
    updated_by       VARCHAR(50)
);
