INSERT INTO Data_Compare_Config
(table_name, source_db, target_db, query, query_count, key_column_list, ignore_column_list, compare)
VALUES ('dc_test', 'RDB', 'RDB_MODERN',
        'WITH PaginatedResults AS (
            SELECT dc_test.*,
                   ROW_NUMBER() OVER (ORDER BY dc_test.id ASC) AS RowNum
            FROM dc_test
        )
        SELECT *
        FROM PaginatedResults
        WHERE RowNum BETWEEN :startRow AND :endRow;
        ',
        'SELECT COUNT(*)
        FROM dc_test;
        ',
        'id',
        'RowNum',
        1);
