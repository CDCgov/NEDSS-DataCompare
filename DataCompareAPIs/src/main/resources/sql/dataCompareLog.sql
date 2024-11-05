CREATE TABLE DataCompare_Log
(
    dc_log_id       BIGINT PRIMARY KEY,
    config_id       BIGINT,
    database        VARCHAR(200),  -- Values from source_db or target_db
    start_date_time DATETIME,
    end_date_time   DATETIME,
    file_name       VARCHAR(100),  -- e.g., rdb.d_patient or rdb_modern.d_patient
    file_location   VARCHAR(1000),
    status          VARCHAR(20) CHECK (status IN ('Inprogress', 'Complete', 'Error')),
    status_desc     VARCHAR(2000), -- Error description or any notes
    FOREIGN KEY (config_id) REFERENCES DataCompare_Config (config_id)
);