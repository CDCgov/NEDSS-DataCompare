IF NOT EXISTS(
    SELECT 'X'
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'Data_Compare_Log')
    BEGIN
        CREATE TABLE Data_Compare_Log
        (
            dc_log_id BIGINT PRIMARY KEY IDENTITY(1,1),
            config_id BIGINT,
            database_table VARCHAR(200),  -- Values from source_db or target_db
            start_date_time DATETIME,
            end_date_time DATETIME,
            file_name VARCHAR(500),
            file_location VARCHAR(1000),
            status VARCHAR(20) CHECK (status IN ('Inprogress', 'Complete', 'Error')),
            status_desc VARCHAR(MAX),
            run_by_user VARCHAR(100),
            rows_compared BIGINT,
            batch_id BIGINT,
            FOREIGN KEY (batch_id) REFERENCES Data_Compare_Batch(batch_id),
            FOREIGN KEY (config_id) REFERENCES Data_Compare_Config(config_id)
        );


    END