CREATE TABLE Data_Compare_Log
(
    dc_log_id       BIGINT PRIMARY KEY,
    table_name      VARCHAR(200),
    database_name        VARCHAR(200),  -- Values from source_db or target_db
    start_date_time DATETIME,
    end_date_time   DATETIME,
    file_location   VARCHAR(1000),
    status          VARCHAR(20) CHECK (status IN ('Inprogress', 'Complete', 'Error')),
    stack_trace VARCHAR(MAX),
    run_by_user varchar(100)
    FOREIGN KEY (table_name) REFERENCES Data_Compare_Config (table_name)
);