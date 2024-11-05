CREATE TABLE Data_Compare_Log
(
    dc_log_id       BIGINT PRIMARY KEY,
    table_name      VARCHAR(200),
    database_name        VARCHAR(200),  -- Values from source_db or target_db
    start_date_time DATETIME,
    end_date_time   DATETIME,
    executed_query VARCHAR(500),
    file_name       VARCHAR(100),  -- e.g., rdb.d_patient or rdb_modern.d_patient
    file_location   VARCHAR(1000),
    status          VARCHAR(20) CHECK (status IN ('Inprogress', 'Complete', 'Error')),
    status_desc     VARCHAR(2000), -- Error description or any notes
    stack_trace VARCHAR(MAX)
    FOREIGN KEY (table_name) REFERENCES Data_Compare_Config (table_name)
);