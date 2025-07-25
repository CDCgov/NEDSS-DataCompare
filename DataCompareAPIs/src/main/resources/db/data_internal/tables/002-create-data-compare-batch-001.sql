IF NOT EXISTS(
    SELECT 'X'
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'Data_Compare_Batch')
    BEGIN
        CREATE TABLE Data_Compare_Batch
        (
            batch_id BIGINT PRIMARY KEY IDENTITY(1,1),
            batch_name VARCHAR(200),
            created_datetime DATETIME,
            updated_datetime DATETIME,
            created_by VARCHAR(50),
            updated_by VARCHAR(50)
        );

    END