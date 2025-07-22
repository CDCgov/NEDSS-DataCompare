INSERT INTO Data_Compare_Config
(
    table_name, source_db, target_db, query, query_count, key_column_list, ignore_column_list, compare,
    target_table_name, target_query, target_query_count
)
VALUES
    (
        'PublicHealthCaseFact', 'ODSE', 'ODSE',
        'WITH PaginatedResults AS (
            SELECT PublicHealthCaseFact.*,
                   ROW_NUMBER() OVER (ORDER BY PublicHealthCaseFact.public_health_case_uid ASC) AS RowNum
            FROM PublicHealthCaseFact
        )
        SELECT *
        FROM PaginatedResults
        WHERE RowNum BETWEEN :startRow AND :endRow;',
        'SELECT COUNT(*) FROM PublicHealthCaseFact;',
        'public_health_case_uid',
        'RowNum',
        1,
        'PublicHealthCaseFact_modern',
        'WITH PaginatedResults AS (
            SELECT PublicHealthCaseFact_modern.*,
                   ROW_NUMBER() OVER (ORDER BY PublicHealthCaseFact_modern.public_health_case_uid ASC) AS RowNum
            FROM PublicHealthCaseFact_modern
        )
        SELECT *
        FROM PaginatedResults
        WHERE RowNum BETWEEN :startRow AND :endRow;',
        'SELECT COUNT(*) FROM PublicHealthCaseFact_modern;'
    ),
    (
        'SubjectRaceInfo', 'ODSE', 'ODSE',
        'WITH PaginatedResults AS (
            SELECT SubjectRaceInfo.*,
                   ROW_NUMBER() OVER (ORDER BY SubjectRaceInfo.public_health_case_uid ASC) AS RowNum
            FROM SubjectRaceInfo
        )
        SELECT *
        FROM PaginatedResults
        WHERE RowNum BETWEEN :startRow AND :endRow;',
        'SELECT COUNT(*) FROM SubjectRaceInfo;',
        'public_health_case_uid',
        'RowNum',
        1,
        'SubjectRaceInfo_Modern',
        'WITH PaginatedResults AS (
            SELECT SubjectRaceInfo_Modern.*,
                   ROW_NUMBER() OVER (ORDER BY SubjectRaceInfo_Modern.public_health_case_uid ASC) AS RowNum
            FROM SubjectRaceInfo_Modern
        )
        SELECT *
        FROM PaginatedResults
        WHERE RowNum BETWEEN :startRow AND :endRow;',
        'SELECT COUNT(*) FROM SubjectRaceInfo_Modern;'
    );