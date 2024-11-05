insert into Data_Compare_Config
(table_name, source_db, target_db, rdb_sql_query, rdb_sql_count_query, rdb_modern_sql_query, rdb_modern_sql_count_query)
values ('D_PATIENT', 'RDB', 'RDB_MODERN',
        'WITH PaginatedResults AS (
            SELECT D_PATIENT.*,
                   ROW_NUMBER() OVER (ORDER BY D_PATIENT.PATIENT_MPR_UID ASC) AS RowNum
            FROM D_PATIENT
        )
        SELECT *
        FROM PaginatedResults
        WHERE RowNum BETWEEN :startRow AND :endRow;
        ',
        'SELECT COUNT(*)
        FROM D_PATIENT;
        ',
        'WITH PaginatedResults AS (
            SELECT D_PATIENT.*,
                   ROW_NUMBER() OVER (ORDER BY D_PATIENT.PATIENT_MPR_UID ASC) AS RowNum
            FROM D_PATIENT
        )
        SELECT *
        FROM PaginatedResults
        WHERE RowNum BETWEEN :startRow AND :endRow;
        ',
        'SELECT COUNT(*)
        FROM D_PATIENT;
        ');