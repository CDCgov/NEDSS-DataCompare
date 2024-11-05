CREATE TABLE DataCompare_Config
(
    config_id        BIGINT PRIMARY KEY,
    source_db        VARCHAR(100),
    target_db        VARCHAR(100),
    table_name       VARCHAR(200),
    sql_query        VARCHAR(5000),
    compare          BIT,
    use_query        BIT,
    file_type        VARCHAR(20),
    storage_location VARCHAR(200),
    created_datetime DATETIME DEFAULT GETDATE(),
    updated_datetime DATETIME DEFAULT GETDATE(),
    created_by       VARCHAR(50),
    updated_by       VARCHAR(50)
);
