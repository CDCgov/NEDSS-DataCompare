update Data_Compare_Config
set query_rtr       = 'WITH PaginatedResults AS (
            SELECT D_PATIENT.*,
                   ROW_NUMBER() OVER (ORDER BY D_PATIENT.PATIENT_UID ASC) AS RowNum
            FROM D_PATIENT
        )
        SELECT *
        FROM PaginatedResults
        WHERE RowNum BETWEEN :startRow AND :endRow;
        ',
    query_rtr_count = 'SELECT COUNT(*)
        FROM D_PATIENT;
        '
    where table_name = 'D_PATIENT'
