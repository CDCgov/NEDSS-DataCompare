insert into Data_Compare_Config
(table_name, source_db, target_db, query, query_count, key_column_list, ignore_column_list, compare)
values ('D_PATIENT', 'RDB', 'RDB_MODERN',
        'WITH PaginatedResults AS (
            SELECT D_PATIENT.*,
                   ROW_NUMBER() OVER (ORDER BY D_PATIENT.PATIENT_UID ASC) AS RowNum
            FROM D_PATIENT
        )
        SELECT *
        FROM PaginatedResults
        WHERE RowNum BETWEEN :startRow AND :endRow;
        ',
        'SELECT COUNT(*)
        FROM D_PATIENT;
        ',
        'PATIENT_UID',
        'RowNum, PATIENT_KEY, PATIENT_LAST_CHANGE_TIME, PATIENT_ADD_TIME',
        1),
       (
               'D_ORGANIZATION',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_ORGANIZATION.*,
                          ROW_NUMBER() OVER (ORDER BY D_ORGANIZATION.ORGANIZATION_UID ASC) AS RowNum
                   FROM D_ORGANIZATION
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_ORGANIZATION;',
               'ORGANIZATION_UID',
               'RowNum, ORGANIZATION_KEY, ORGANIZATION_LAST_CHANGE_TIME, ORGANIZATION_ADD_TIME',
               1
       ),
       (
               'D_PROVIDER',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_PROVIDER.*,
                          ROW_NUMBER() OVER (ORDER BY D_PROVIDER.PROVIDER_UID ASC) AS RowNum
                   FROM D_PROVIDER
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_PROVIDER;',
               'PROVIDER_UID',
               'RowNum, PROVIDER_KEY, PROVIDER_LAST_CHANGE_TIME, PROVIDER_ADD_TIME',
               1
       ),
       (
               'RDB_DATE',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT RDB_DATE.*,
                          ROW_NUMBER() OVER (ORDER BY RDB_DATE.DATE_MM_DD_YYYY ASC) AS RowNum
                   FROM RDB_DATE
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM RDB_DATE;',
               'DATE_MM_DD_YYYY',
               'RowNum',
               1
       ),
       (
               'CONFIRMATION_METHOD_GROUP',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT CONFIRMATION_METHOD_GROUP.*,
                          ROW_NUMBER() OVER (ORDER BY CONFIRMATION_METHOD_GROUP.INVESTIGATION_KEY ASC) AS RowNum
                   FROM CONFIRMATION_METHOD_GROUP
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM CONFIRMATION_METHOD_GROUP;',
               'INVESTIGATION_KEY',
               'RowNum, CONFIRMATION_DT',
               1
       ),
       (
               'CONFIRMATION_METHOD',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT CONFIRMATION_METHOD.*,
                          ROW_NUMBER() OVER (ORDER BY CONFIRMATION_METHOD.CONFIRMATION_METHOD_CD ASC) AS RowNum
                   FROM CONFIRMATION_METHOD
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM CONFIRMATION_METHOD;',
               'CONFIRMATION_METHOD_CD',
               'RowNum',
               1
       ),
       (
               'INVESTIGATION',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT INVESTIGATION.*,
                          ROW_NUMBER() OVER (ORDER BY INVESTIGATION.CASE_UID ASC) AS RowNum
                   FROM INVESTIGATION
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM INVESTIGATION;',
               'CASE_UID',
               'RowNum, INVESTIGATION_KEY, ADD_TIME, LAST_CHG_TIME',
               1
       ),
       (
               'LDF_GROUP',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT LDF_GROUP.*,
                          ROW_NUMBER() OVER (ORDER BY LDF_GROUP.BUSINESS_OBJECT_UID ASC) AS RowNum
                   FROM LDF_GROUP
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM LDF_GROUP;',
               'BUSINESS_OBJECT_UID',
               'RowNum',
               1
       ),
       (
               'D_INV_ADMINISTRATIVE',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_ADMINISTRATIVE.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_ADMINISTRATIVE.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_ADMINISTRATIVE
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_ADMINISTRATIVE;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_ADMINISTRATIVE_KEY',
               1
       ),
       (
               'D_INV_CLINICAL',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_CLINICAL.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_CLINICAL.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_CLINICAL
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_CLINICAL;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_CLINICAL_KEY',
               1
       ),
       (
               'D_INV_COMPLICATION',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_COMPLICATION.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_COMPLICATION.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_COMPLICATION
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_COMPLICATION;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_COMPLICATION_KEY',
               1
       ),
       (
               'D_INV_CONTACT',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_CONTACT.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_CONTACT.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_CONTACT
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_CONTACT;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_CONTACT_KEY',
               1
       ),
       (
               'D_INV_DEATH',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_DEATH.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_DEATH.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_DEATH
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_DEATH;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_DEATH_KEY',
               1
       ),
       (
               'D_INV_EPIDEMIOLOGY',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_EPIDEMIOLOGY.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_EPIDEMIOLOGY.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_EPIDEMIOLOGY
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_EPIDEMIOLOGY;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_EPIDEMIOLOGY_KEY',
               1
       ),
       (
               'D_INV_HIV',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_HIV.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_HIV.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_HIV
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_HIV;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_HIV_KEY',
               1
       ),
       (
               'D_INV_ISOLATE_TRACKING',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_ISOLATE_TRACKING.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_ISOLATE_TRACKING.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_ISOLATE_TRACKING
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_ISOLATE_TRACKING;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_ISOLATE_TRACKING_KEY',
               1
       ),
       (
               'D_INV_LAB_FINDING',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_LAB_FINDING.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_LAB_FINDING.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_LAB_FINDING
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_LAB_FINDING;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_LAB_FINDING_KEY',
               1
       ),
       (
               'D_INV_MEDICAL_HISTORY',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_MEDICAL_HISTORY.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_MEDICAL_HISTORY.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_MEDICAL_HISTORY
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_MEDICAL_HISTORY;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_MEDICAL_HISTORY_KEY',
               1
       ),
       (
               'D_INV_MOTHER',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_MOTHER.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_MOTHER.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_MOTHER
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_MOTHER;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_MOTHER_KEY',
               1
       ),
       (
               'D_INV_OTHER',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_OTHER.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_OTHER.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_OTHER
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_OTHER;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_OTHER_KEY',
               1
       ),
       (
               'D_INV_PATIENT_OBS',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_PATIENT_OBS.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_PATIENT_OBS.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_PATIENT_OBS
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_PATIENT_OBS;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_PATIENT_OBS_KEY',
               1
       ),
       (
               'D_INV_PREGNANCY_BIRTH',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_PREGNANCY_BIRTH.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_PREGNANCY_BIRTH.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_PREGNANCY_BIRTH
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_PREGNANCY_BIRTH;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_PREGNANCY_BIRTH_KEY',
               1
       ),
       (
               'D_INV_RESIDENCY',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_RESIDENCY.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_RESIDENCY.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_RESIDENCY
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_RESIDENCY;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_RESIDENCY_KEY',
               1
       ),
       (
               'D_INV_RISK_FACTOR',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_RISK_FACTOR.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_RISK_FACTOR.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_RISK_FACTOR
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_RISK_FACTOR;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_RISK_FACTOR_KEY',
               1
       ),
       (
               'D_INV_SOCIAL_HISTORY',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_SOCIAL_HISTORY.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_SOCIAL_HISTORY.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_SOCIAL_HISTORY
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_SOCIAL_HISTORY;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_SOCIAL_HISTORY_KEY',
               1
       ),
       (
               'D_INV_SYMPTOM',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_SYMPTOM.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_SYMPTOM.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_SYMPTOM
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_SYMPTOM;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_SYMPTOM_KEY',
               1
       ),
       (
               'D_INV_TRAVEL',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_TRAVEL.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_TRAVEL.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_TRAVEL
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_TRAVEL;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_TRAVEL_KEY',
               1
       ),
       (
               'D_INV_TREATMENT',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_TREATMENT.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_TREATMENT.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_TREATMENT
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_TREATMENT;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_TREATMENT_KEY',
               1
       ),
       (
               'D_INV_UNDER_CONDITION',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_UNDER_CONDITION.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_UNDER_CONDITION.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_UNDER_CONDITION
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_UNDER_CONDITION;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_UNDER_CONDITION_KEY',
               1
       ),
       (
               'D_INV_VACCINATION',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT D_INV_VACCINATION.*,
                          ROW_NUMBER() OVER (ORDER BY D_INV_VACCINATION.nbs_case_answer_uid ASC) AS RowNum
                   FROM D_INV_VACCINATION
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM D_INV_VACCINATION;',
               'nbs_case_answer_uid',
               'RowNum, D_INV_VACCINATION_KEY',
               1
       ),
       (
               'HEPATITIS_DATAMART',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT DISTINCT HEPATITIS_DATAMART.*,
                          CONCAT(inv_local_id, pat_local_id, patient_uid, case_uid) AS CONCAT_KEY,
                          ROW_NUMBER() OVER (ORDER BY CONCAT(inv_local_id, pat_local_id, patient_uid, case_uid) ASC) AS RowNum
                   FROM HEPATITIS_DATAMART
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(DISTINCT CONCAT(inv_local_id, pat_local_id, patient_uid, case_uid))
               FROM HEPATITIS_DATAMART;',
               'CONCAT_KEY',
               'RowNum, REFRESH_DATETIME',
               1
       ),
       (
               'D_INVESTIGATION_REPEAT',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT DISTINCT D_INVESTIGATION_REPEAT.*,
                          CONCAT(page_case_uid, block_nm) AS CONCAT_KEY,
                          ROW_NUMBER() OVER (ORDER BY CONCAT(page_case_uid, block_nm) ASC) AS RowNum
                   FROM D_INVESTIGATION_REPEAT
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(DISTINCT CONCAT(page_case_uid, block_nm))
               FROM D_INVESTIGATION_REPEAT;',
               'CONCAT_KEY',
               'RowNum, D_INVESTIGATION_REPEAT_KEY',
               1
       ),
       (
               'NOTIFICATION',
               'RDB',
               'RDB_MODERN',
               'WITH PaginatedResults AS (
                   SELECT DISTINCT NOTIFICATION.*,
                          ROW_NUMBER() OVER (ORDER BY NOTIFICATION.notification_local_id ASC) AS RowNum
                   FROM NOTIFICATION
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;',
               'SELECT COUNT(*)
               FROM NOTIFICATION;',
               'NOTIFICATION_LOCAL_ID',
               'RowNum, NOTIFICATION_LAST_CHANGE_TIME',
               1
       ),
       (
       		'NOTIFICATION_EVENT',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                         SELECT DISTINCT NOTIFICATION_EVENT.*,
                                ROW_NUMBER() OVER (ORDER BY NOTIFICATION_EVENT.INVESTIGATION_KEY ASC) AS RowNum
                         FROM NOTIFICATION_EVENT
                      )
                      SELECT *
                      FROM PaginatedResults
                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                      FROM NOTIFICATION_EVENT;',
       		'NOTIFICATION_KEY',
       		'RowNum , NOTIFICATION_KEY',
       		1
       		),
       	(
       		'LDF_DATA',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LDF_DATA.*,
                                                ROW_NUMBER() OVER (ORDER BY LDF_DATA.LDF_GROUP_KEY ASC) AS RowNum
                                         FROM LDF_DATA
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LDF_DATA;',
       		'LDF_DATA_KEY',
       		'RowNum, LDF_DATA_KEY',
       		1
       		),
       	(
       		'ORGANIZATION_LDF_GROUP',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT ORGANIZATION_LDF_GROUP.*,
                                                ROW_NUMBER() OVER (ORDER BY ORGANIZATION_LDF_GROUP.LDF_GROUP_KEY ASC) AS RowNum
                                         FROM LDF_PROVIDER_GROUP
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM ORGANIZATION_LDF_GROUP;',
       		'ORGANIZATION_KEY',
       		'RowNum, ORGANIZATION_KEY',
       		1
       		),
       	(
       		'PATIENT_LDF_GROUP',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT PATIENT_LDF_GROUP.*,
                                                ROW_NUMBER() OVER (ORDER BY PATIENT_LDF_GROUP.LDF_GROUP_KEY ASC) AS RowNum
                                         FROM PATIENT_LDF_GROUP
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM PATIENT_LDF_GROUP;',
       		'PATIENT_KEY',
       		'RowNum, PATIENT_KEY',
       		1
       		),
       	(
       		'PROVIDER_LDF_GROUP',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT PROVIDER_LDF_GROUP.*,
                                                ROW_NUMBER() OVER (ORDER BY PROVIDER_LDF_GROUP.LDF_GROUP_KEY ASC) AS RowNum
                                         FROM PROVIDER_LDF_GROUP
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM PROVIDER_LDF_GROUP;',
       		'PROVIDER_KEY',
       		'RowNum, PROVIDER_KEY',
       		1
       		),
       	(
       		'F_PAGE_CASE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT F_PAGE_CASE.*,
                                                ROW_NUMBER() OVER (ORDER BY F_PAGE_CASE.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM F_PAGE_CASE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM F_PAGE_CASE;',
       		'INVESTIGATION_KEY',
       		'RowNum, ADD_DATE_KEY, LAST_CHG_DATE_KEY',
       		1
       		),
       	(
       		'LAB_TEST',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LAB_TEST.*,
                                                ROW_NUMBER() OVER (ORDER BY LAB_TEST.LAB_TEST_KEY ASC) AS RowNum
                                         FROM LAB_TEST
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LAB_TEST;',
       		'LAB_TEST_KEY',
       		'RowNum, LAB_TEST_KEY',
       		1
       		),
       	(
       		'LAB_RPT_USER_COMMENT',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LAB_RPT_USER_COMMENT.*,
                                                ROW_NUMBER() OVER (ORDER BY LAB_RPT_USER_COMMENT.LAB_TEST_KEY ASC) AS RowNum
                                         FROM LAB_RPT_USER_COMMENT
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LAB_RPT_USER_COMMENT;',
       		'LAB_TEST_KEY',
       		'RowNum, LAB_TEST_KEY',
       		1
       		),
       	(
       		'MORBIDITY_REPORT  ',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT MORBIDITY_REPORT  .*,
                                                ROW_NUMBER() OVER (ORDER BY MORBIDITY_REPORT.MORB_RPT_KEY ASC) AS RowNum
                                         FROM MORBIDITY_REPORT
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM MORBIDITY_REPORT ;',
       		'MORB_RPT_KEY',
       		'RowNum, MORB_RPT_KEY',
       		1
       		),
       	(
       		'MORBIDITY_REPORT_EVENT',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT MORBIDITY_REPORT_EVENT.*,
                                                ROW_NUMBER() OVER (ORDER BY MORBIDITY_REPORT_EVENT.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM MORBIDITY_REPORT_EVENT
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM MORBIDITY_REPORT_EVENT;',
       		'MORB_RPT_KEY',
       		'RowNum, MORB_RPT_KEY',
       		1
       		),
       	(
       		'MORB_RPT_USER_COMMENT',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT MORB_RPT_USER_COMMENT.*,
                                                ROW_NUMBER() OVER (ORDER BY MORB_RPT_USER_COMMENT.MORB_RPT_KEY ASC) AS RowNum
                                         FROM MORB_RPT_USER_COMMENT
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM MORB_RPT_USER_COMMENT;',
       		'MORB_RPT_KEY',
       		'RowNum, MORB_RPT_KEY',
       		1
       		),
       	--till here 13:53-14:08
       	(
       		'LAB_TEST_RESULT',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LAB_TEST_RESULT.*,
                                                ROW_NUMBER() OVER (ORDER BY LAB_TEST_RESULT.LAB_TEST_KEY ASC) AS RowNum
                                         FROM LAB_TEST_RESULT
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LAB_TEST_RESULT;',
       		'LAB_TEST_KEY',
       		'RowNum, LAB_TEST_KEY',
       		1
       		),
       	(
       		'LAB_RESULT_COMMENT',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LAB_RESULT_COMMENT.*,
                                                ROW_NUMBER() OVER (ORDER BY LAB_RESULT_COMMENT.LAB_TEST_UID ASC) AS RowNum
                                         FROM LAB_RESULT_COMMENT
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LAB_RESULT_COMMENT;',
       		'LAB_TEST_UID',
       		'RowNum, LAB_TEST_UID',
       		1
       		),
       	(
       		'LAB_RESULT_VAL',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LAB_RESULT_VAL.*,
                                                ROW_NUMBER() OVER (ORDER BY LAB_RESULT_VAL.LAB_TEST_UID ASC) AS RowNum
                                         FROM LAB_RESULT_VAL
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LAB_RESULT_VAL;',
       		'LAB_TEST_UID',
       		'RowNum, LAB_TEST_UID',
       		1
       		),
       	(
       		'LAB100',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LAB100.*,
                                                ROW_NUMBER() OVER (ORDER BY LAB100.LAB_RPT_LOCAL_ID ASC) AS RowNum
                                         FROM LAB100
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LAB100;',
       		'LAB_RPT_LOCAL_ID',
       		'RowNum, LAB_RPT_LOCAL_ID',
       		1
       		),
       	(
       		'LAB101',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LAB101.*,
                                                ROW_NUMBER() OVER (ORDER BY LAB101.RESULTED_LAB_TEST_KEY ASC) AS RowNum
                                         FROM LAB101
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LAB101;',
       		'RESULTED_LAB_TEST_KEY',
       		'RowNum, RESULTED_LAB_TEST_KEY',
       		1
       		),
       	(
       		'Codeset',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT Codeset.*,
                                                ROW_NUMBER() OVER (ORDER BY Codeset.CD ASC) AS RowNum
                                         FROM Codeset
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM Codeset;',
       		'CD',
       		'RowNum, CD',
       		1
       		),
       	(
       		'D_INTERVIEW',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT D_INTERVIEW.*,
                                                ROW_NUMBER() OVER (ORDER BY D_INTERVIEW.D_INTERVIEW_KEY ASC) AS RowNum
                                         FROM D_INTERVIEW
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_INTERVIEW;',
       		'D_INTERVIEW_KEY',
       		'RowNum, D_INTERVIEW_KEY',
       		1
       		),
       	(
       		'D_INTERVIEW_NOTE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT D_INTERVIEW_NOTE.*,
                                                ROW_NUMBER() OVER (ORDER BY D_INTERVIEW_NOTE.NBS_ANSWER_UID ASC) AS RowNum
                                         FROM D_INTERVIEW_NOTE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_INTERVIEW_NOTE;',
       		'D_INTERVIEW_NOTE_KEY',
       		'RowNum, D_INTERVIEW_NOTE_KEY',
       		1
       		),
       	(
       		'D_CASE_MANAGEMENT',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT D_CASE_MANAGEMENT.*,
                                                ROW_NUMBER() OVER (ORDER BY D_CASE_MANAGEMENT.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM D_CASE_MANAGEMENT
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_CASE_MANAGEMENT;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'CASE_COUNT',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CASE_COUNT.*,
                                                ROW_NUMBER() OVER (ORDER BY CASE_COUNT.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM Case_Count
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM CASE_COUNT;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'TOTALIDM',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT TOTALIDM.*,
                                                ROW_NUMBER() OVER (ORDER BY TOTALIDM.TotalIDM_id ASC) AS RowNum
                                         FROM TOTALIDM
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM TOTALIDM;',
       		'TotalIDM_id',
       		'RowNum, TotalIDM_id',
       		1
       		),
       	(
       		'F_INTERVIEW_CASE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT F_INTERVIEW_CASE.*,
                                                ROW_NUMBER() OVER (ORDER BY F_INTERVIEW_CASE.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM F_INTERVIEW_CASE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM F_INTERVIEW_CASE;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'STD_HIV_DATAMART',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT STD_HIV_DATAMART.*,
                                                ROW_NUMBER() OVER (ORDER BY STD_HIV_DATAMART.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM STD_HIV_DATAMART
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM STD_HIV_DATAMART;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'INV_HIV',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT INV_HIV.*,
                                                ROW_NUMBER() OVER (ORDER BY INV_HIV.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM INV_HIV
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM INV_HIV;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'F_STD_PAGE_CASE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT F_STD_PAGE_CASE.*,
                                                ROW_NUMBER() OVER (ORDER BY F_STD_PAGE_CASE.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM F_STD_PAGE_CASE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM F_STD_PAGE_CASE;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'CODE_VAL_GENERAL',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CODE_VAL_GENERAL.*,
                                                ROW_NUMBER() OVER (ORDER BY CODE_VAL_GENERAL.CODE_KEY ASC) AS RowNum
                                         FROM CODE_VAL_GENERAL
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM CODE_VAL_GENERAL;',
       		'CODE_KEY',
       		'RowNum, CODE_KEY',
       		1
       		),
       	(
       		'CONDITION',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CONDITION.*,
                                                ROW_NUMBER() OVER (ORDER BY CONDITION.CONDITION_KEY ASC) AS RowNum
                                         FROM CONDITION
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM CONDITION;',
       		'CONDITION_KEY',
       		'RowNum, CONDITION_KEY',
       		1
       		),
       	(
       		'D_PLACE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT D_PLACE.*,
                                                ROW_NUMBER() OVER (ORDER BY D_PLACE.PLACE_UID ASC) AS RowNum
                                         FROM D_PLACE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_PLACE;',
       		'PLACE_UID',
       		'RowNum',
       		1
       		),
       	(
       		'GENERIC_CASE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT GENERIC_CASE.*,
                                                ROW_NUMBER() OVER (ORDER BY GENERIC_CASE.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM GENERIC_CASE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM GENERIC_CASE;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'CRS_CASE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CRS_CASE.*,
                                                ROW_NUMBER() OVER (ORDER BY CRS_CASE.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM CRS_CASE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM CRS_CASE;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'BMIRD_CASE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT BMIRD_CASE.*,
                                                ROW_NUMBER() OVER (ORDER BY BMIRD_CASE.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM BMIRD_CASE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM BMIRD_CASE;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'MEASLES_CASE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT MEASLES_CASE.*,
                                                ROW_NUMBER() OVER (ORDER BY MEASLES_CASE.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM MEASLES_CASE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM MEASLES_CASE;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	--TILL HERE
       	(
       		'ANTIMICROBIAL',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT ANTIMICROBIAL.*,
                                                ROW_NUMBER() OVER (ORDER BY ANTIMICROBIAL.ANTIMICROBIAL_KEY ASC) AS RowNum
                                         FROM ANTIMICROBIAL
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM ANTIMICROBIAL;',
       		'ANTIMICROBIAL_KEY',
       		'RowNum, ANTIMICROBIAL_KEY',
       		1
       		),
       	(
       		'ANTIMICROBIAL_GROUP',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                                         SELECT DISTINCT ANTIMICROBIAL_GROUP.*,
                                                                ROW_NUMBER() OVER (ORDER BY ANTIMICROBIAL_GROUP.ANTIMICROBIAL_GRP_KEY ASC) AS RowNum
                                                         FROM ANTIMICROBIAL_GROUP
                                                      )
                                                      SELECT *
                                                      FROM PaginatedResults
                                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                                      FROM ANTIMICROBIAL_GROUP;',
       		'ANTIMICROBIAL_GRP_KEY',
       		'RowNum, ANTIMICROBIAL_GRP_KEY',
       		1
       		),
       	(
       		'TREATMENT_EVENT',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT TREATMENT_EVENT.*,
                                                ROW_NUMBER() OVER (ORDER BY TREATMENT_EVENT.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM TREATMENT_EVENT
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM TREATMENT_EVENT;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'BMIRD_MULTI_VALUE_FIELD_GROUP',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT BMIRD_MULTI_VALUE_FIELD_GROUP.*,
                                                ROW_NUMBER() OVER (ORDER BY BMIRD_MULTI_VALUE_FIELD_GROUP.BMIRD_MULTI_VAL_GRP_KEY ASC) AS RowNum
                                         FROM BMIRD_MULTI_VALUE_FIELD_GROUP
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM BMIRD_MULTI_VALUE_FIELD_GROUP;',
       		'BMIRD_MULTI_VAL_GRP_KEY',
       		'RowNum, BMIRD_MULTI_VAL_GRP_KEY',
       		1
       		),
       	(
       		'BMIRD_MULTI_VALUE_FIELD',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT BMIRD_MULTI_VALUE_FIELD.*,
                                                ROW_NUMBER() OVER (ORDER BY BMIRD_MULTI_VALUE_FIELD.BMIRD_MULTI_VAL_FIELD_KEY ASC) AS RowNum
                                         FROM BMIRD_MULTI_VALUE_FIELD
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM BMIRD_MULTI_VALUE_FIELD;',
       		'BMIRD_MULTI_VAL_FIELD_KEY',
       		'RowNum, BMIRD_MULTI_VAL_FIELD_KEY',
       		1
       		),
       	(
       		'USER_PROFILE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT USER_PROFILE.*,
                                                ROW_NUMBER() OVER (ORDER BY USER_PROFILE.NEDSS_ENTRY_ID ASC) AS RowNum
                                         FROM USER_PROFILE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM USER_PROFILE;',
       		'NEDSS_ENTRY_ID',
       		'RowNum, NEDSS_ENTRY_ID',
       		1
       		),
       	(
       		'CASE_LAB_DATAMART',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CASE_LAB_DATAMART.*,
                                                ROW_NUMBER() OVER (ORDER BY CASE_LAB_DATAMART.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM CASE_LAB_DATAMART
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM CASE_LAB_DATAMART;',
       		'INVESTIGATION_LOCAL_ID',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'EVENT_METRIC',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT EVENT_METRIC.*,
                                                ROW_NUMBER() OVER (ORDER BY EVENT_METRIC.EVENT_UID ASC) AS RowNum
                                         FROM EVENT_METRIC
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM EVENT_METRIC;',
       		'EVENT_UID',
       		'RowNum, EVENT_UID, LAST_CHG_TIME',
       		1
       		),
       	(
       		'D_VACCINATION',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT D_VACCINATION.*,
                                                ROW_NUMBER() OVER (ORDER BY D_VACCINATION.VACCINATION_UID ASC) AS RowNum
                                         FROM D_VACCINATION
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_VACCINATION;',
       		'VACCINATION_UID',
       		'RowNum, VACCINATION_KEY',
       		1
       		),
       	(
       		'F_VACCINATION',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT F_VACCINATION.*,
                                                ROW_NUMBER() OVER (ORDER BY F_VACCINATION.PATIENT_KEY ASC) AS RowNum
                                         FROM F_VACCINATION
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM F_VACCINATION;',
       		'PATIENT_KEY',
       		'RowNum, PATIENT_KEY',
       		1
       		),
       	(
       		'HEP100',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT HEP100.*,
                                                ROW_NUMBER() OVER (ORDER BY HEP100.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM HEP100
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM HEP100;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'BMIRD_STREP_PNEUMO_DATAMART',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT BMIRD_STREP_PNEUMO_DATAMART.*,
                                                ROW_NUMBER() OVER (ORDER BY BMIRD_STREP_PNEUMO_DATAMART.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM BMIRD_STREP_PNEUMO_DATAMART
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM BMIRD_STREP_PNEUMO_DATAMART;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'MORBIDITY_REPORT_DATAMART',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT MORBIDITY_REPORT_DATAMART.*,
                                                ROW_NUMBER() OVER (ORDER BY MORBIDITY_REPORT_DATAMART.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM MORBIDITY_REPORT_DATAMART
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM MORBIDITY_REPORT_DATAMART;',
       		'MORBIDITY_REPORT_KEY',
       		'RowNum, MORBIDITY_REPORT_KEY',
       		1
       		),
       	(
       		'RUBELLA_CASE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT RUBELLA_CASE.*,
                                                ROW_NUMBER() OVER (ORDER BY RUBELLA_CASE.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM RUBELLA_CASE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM RUBELLA_CASE;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'PERTUSSIS_CASE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT PERTUSSIS_CASE.*,
                                                ROW_NUMBER() OVER (ORDER BY PERTUSSIS_CASE.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM PERTUSSIS_CASE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM PERTUSSIS_CASE;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'HEPATITIS_CASE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT HEPATITIS_CASE.*,
                                                ROW_NUMBER() OVER (ORDER BY HEPATITIS_CASE.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM HEPATITIS_CASE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM HEPATITIS_CASE;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'D_INV_PLACE_REPEAT',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT D_INV_PLACE_REPEAT.*,
                                                ROW_NUMBER() OVER (ORDER BY D_INV_PLACE_REPEAT.D_INV_PLACE_REPEAT_KEY ASC) AS RowNum
                                         FROM D_INV_PLACE_REPEAT
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_INV_PLACE_REPEAT;',
       		'D_INV_PLACE_REPEAT_KEY',
       		'RowNum, D_INV_PLACE_REPEAT_KEY',
       		1
       		),
       	(
       		'HEP_MULTI_VALUE_FIELD_GROUP',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT HEP_MULTI_VALUE_FIELD_GROUP.*,
                                                ROW_NUMBER() OVER (ORDER BY HEP_MULTI_VALUE_FIELD_GROUP.HEP_MULTI_VAL_GRP_KEY ASC) AS RowNum
                                         FROM HEP_MULTI_VALUE_FIELD_GROUP
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM HEP_MULTI_VALUE_FIELD_GROUP;',
       		'HEP_MULTI_VAL_GRP_KEY',
       		'RowNum, HEP_MULTI_VAL_GRP_KEY',
       		1
       		),
       	(
       		'HEP_MULTI_VALUE_FIELD',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT HEP_MULTI_VALUE_FIELD.*,
                                                ROW_NUMBER() OVER (ORDER BY HEP_MULTI_VALUE_FIELD.HEP_MULTI_VAL_DATA_KEY ASC) AS RowNum
                                         FROM HEP_MULTI_VALUE_FIELD
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM HEP_MULTI_VALUE_FIELD;',
       		'HEP_MULTI_VAL_DATA_KEY',
       		'RowNum, HEP_MULTI_VAL_DATA_KEY',
       		1
       		),
       	(
       		'PERTUSSIS_SUSPECTED_SOURCE_FLD',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT PERTUSSIS_SUSPECTED_SOURCE_FLD.*,
                                                ROW_NUMBER() OVER (ORDER BY PERTUSSIS_SUSPECTED_SOURCE_FLD.PERTUSSIS_SUSPECT_SRC_FLD_KEY ASC) AS RowNum
                                         FROM PERTUSSIS_SUSPECTED_SOURCE_FLD
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM PERTUSSIS_SUSPECTED_SOURCE_FLD;',
       		'PERTUSSIS_SUSPECT_SRC_FLD_KEY',
       		'RowNum, PERTUSSIS_SUSPECT_SRC_FLD_KEY',
       		1
       		),
       	(
       		'PERTUSSIS_SUSPECTED_SOURCE_GRP',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                                         SELECT DISTINCT PERTUSSIS_SUSPECTED_SOURCE_GRP.*,
                                                                ROW_NUMBER() OVER (ORDER BY PERTUSSIS_SUSPECTED_SOURCE_GRP.PERTUSSIS_SUSPECT_SRC_GRP_KEY ASC) AS RowNum
                                                         FROM PERTUSSIS_SUSPECTED_SOURCE_GRP
                                                      )
                                                      SELECT *
                                                      FROM PaginatedResults
                                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                                      FROM PERTUSSIS_SUSPECTED_SOURCE_GRP;',
       		'PERTUSSIS_SUSPECT_SRC_GRP_KEY',
       		'RowNum, PERTUSSIS_SUSPECT_SRC_GRP_KEY',
       		1
       		),
       	(
       		'PERTUSSIS_TREATMENT_FIELD',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT PERTUSSIS_TREATMENT_FIELD.*,
                                                ROW_NUMBER() OVER (ORDER BY PERTUSSIS_TREATMENT_FIELD.PERTUSSIS_TREATMENT_FLD_KEY ASC) AS RowNum
                                         FROM PERTUSSIS_TREATMENT_FIELD
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM PERTUSSIS_TREATMENT_FIELD;',
       		'PERTUSSIS_TREATMENT_FLD_KEY',
       		'RowNum, PERTUSSIS_TREATMENT_FLD_KEY',
       		1
       		),
       	(
       		'PERTUSSIS_TREATMENT_GROUP',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                                         SELECT DISTINCT PERTUSSIS_TREATMENT_GROUP.*,
                                                                ROW_NUMBER() OVER (ORDER BY PERTUSSIS_TREATMENT_GROUP.PERTUSSIS_TREATMENT_GRP_KEY ASC) AS RowNum
                                                         FROM PERTUSSIS_TREATMENT_GROUP
                                                      )
                                                      SELECT *
                                                      FROM PaginatedResults
                                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                                      FROM PERTUSSIS_TREATMENT_GROUP;',
       		'PERTUSSIS_TREATMENT_GRP_KEY',
       		'RowNum, PERTUSSIS_TREATMENT_GRP_KEY',
       		1
       		),
       	(
       		'F_CONTACT_RECORD_CASE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT F_CONTACT_RECORD_CASE.*,
                                                ROW_NUMBER() OVER (ORDER BY F_CONTACT_RECORD_CASE.D_CONTACT_RECORD_KEY ASC) AS RowNum
                                         FROM F_CONTACT_RECORD_CASE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM F_CONTACT_RECORD_CASE;',
       		'D_CONTACT_RECORD_KEY',
       		'RowNum, D_CONTACT_RECORD_KEY',
       		1
       		),
       	(
       		'INV_SUMM_DATAMART',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT INV_SUMM_DATAMART.*,
                                                ROW_NUMBER() OVER (ORDER BY INV_SUMM_DATAMART.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM INV_SUMM_DATAMART
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM INV_SUMM_DATAMART;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'D_TB_HIV',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT D_TB_HIV.*,
                                                ROW_NUMBER() OVER (ORDER BY D_TB_HIV.D_TB_HIV_KEY ASC) AS RowNum
                                         FROM D_TB_HIV
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_TB_HIV;',
       		'D_TB_HIV_KEY',
       		'RowNum, D_TB_HIV_KEY, LAST_CHG_TIME',
       		1
       		),
       	(
       		'D_TB_PAM',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT D_TB_PAM.*,
                                                ROW_NUMBER() OVER (ORDER BY D_TB_PAM.D_TB_PAM_KEY ASC) AS RowNum
                                         FROM D_TB_PAM
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_TB_PAM;',
       		'D_TB_PAM_KEY',
       		'RowNum, D_TB_PAM_KEY, LAST_CHG_TIME',
       		1
       		),
       	(
       		'D_VAR_PAM',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT D_VAR_PAM.*,
                                                ROW_NUMBER() OVER (ORDER BY D_VAR_PAM.D_VAR_PAM_KEY ASC) AS RowNum
                                         FROM D_VAR_PAM
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_VAR_PAM;',
       		'D_VAR_PAM_KEY',
       		'RowNum, D_VAR_PAM_KEY',
       		1
       		),
       	(
       		'D_ADDL_RISK',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,D_ADDL_RISK_KEY) AS COMPOSITE_KEY, D_ADDL_RISK.*,
                                                ROW_NUMBER() OVER (ORDER BY D_ADDL_RISK.TB_PAM_UID, D_ADDL_RISK.D_ADDL_RISK_KEY ASC) AS RowNum
                                         FROM D_ADDL_RISK
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_ADDL_RISK;',
       		'COMPOSITE_KEY',
       		'RowNum, COMPOSITE_KEY, TB_PAM_UID, D_ADDL_RISK_KEY',
       		1
       		),
       	(
       		'D_DISEASE_SITE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,D_DISEASE_SITE_KEY) AS COMPOSITE_KEY, D_DISEASE_SITE.*,
                                                ROW_NUMBER() OVER (ORDER BY D_DISEASE_SITE.TB_PAM_UID,D_DISEASE_SITE.D_DISEASE_SITE_KEY ASC) AS RowNum
                                         FROM D_DISEASE_SITE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_DISEASE_SITE;',
       		'COMPOSITE_KEY',
       		'RowNum, COMPOSITE_KEY, TB_PAM_UID, D_DISEASE_SITE_KEY',
       		1
       		),
       	(
       		'D_GT_12_REAS',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,D_GT_12_REAS_KEY) AS COMPOSITE_KEY ,D_GT_12_REAS.*,
                                                ROW_NUMBER() OVER (ORDER BY D_GT_12_REAS.TB_PAM_UID,D_GT_12_REAS.D_GT_12_REAS_KEY ASC) AS RowNum
                                         FROM D_GT_12_REAS
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_GT_12_REAS;',
       		'COMPOSITE_KEY',
       		'RowNum, COMPOSITE_KEY, TB_PAM_UID, D_GT_12_REAS_KEY',
       		1
       		),
       	(
       		'D_HC_PROV_TY_3',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,D_HC_PROV_TY_3_KEY) AS COMPOSITE_KEY , D_HC_PROV_TY_3.*,
                                                ROW_NUMBER() OVER (ORDER BY D_HC_PROV_TY_3.TB_PAM_UID, D_HC_PROV_TY_3.D_HC_PROV_TY_3_KEY ASC) AS RowNum
                                         FROM D_HC_PROV_TY_3
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_HC_PROV_TY_3;',
       		'COMPOSITE_KEY',
       		'RowNum , COMPOSITE_KEY, TB_PAM_UID, D_HC_PROV_TY_3_KEY',
       		1
       		),
       	(
       		'D_MOVE_CNTRY',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,D_MOVE_CNTRY_KEY) AS COMPOSITE_KEY , D_MOVE_CNTRY.*,
                                                ROW_NUMBER() OVER (ORDER BY D_MOVE_CNTRY.TB_PAM_UID,D_MOVE_CNTRY.D_MOVE_CNTRY_KEY ASC) AS RowNum
                                         FROM D_MOVE_CNTRY
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_MOVE_CNTRY;',
       		'COMPOSITE_KEY',
       		'RowNum, COMPOSITE_KEY, TB_PAM_UID, D_MOVE_CNTRY_KEY',
       		1
       		),
       	(
       		'D_MOVE_CNTY',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,D_MOVE_CNTY_KEY) AS COMPOSITE_KEY , D_MOVE_CNTY.*,
                                                ROW_NUMBER() OVER (ORDER BY D_MOVE_CNTY.TB_PAM_UID,D_MOVE_CNTY.D_MOVE_CNTY_KEY ASC) AS RowNum
                                         FROM D_MOVE_CNTY
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_MOVE_CNTY;',
       		'COMPOSITE_KEY',
       		'RowNum, COMPOSITE_KEY, TB_PAM_UID, D_MOVE_CNTY_KEY',
       		1
       		),
       	(
       		'D_MOVE_STATE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,D_MOVE_STATE_KEY) AS COMPOSITE_KEY ,  D_MOVE_STATE.*,
                                                ROW_NUMBER() OVER (ORDER BY D_MOVE_STATE.TB_PAM_UID , D_MOVE_STATE.D_MOVE_STATE_KEY ASC) AS RowNum
                                         FROM D_MOVE_STATE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_MOVE_STATE;',
       		'COMPOSITE_KEY',
       		'RowNum, COMPOSITE_KEY, TB_PAM_UID, D_MOVE_STATE_KEY',
       		1
       		),
       	(
       		'D_MOVED_WHERE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,D_MOVED_WHERE_KEY) AS COMPOSITE_KEY ,  D_MOVED_WHERE.*,
                                                ROW_NUMBER() OVER (ORDER BY D_MOVED_WHERE.TB_PAM_UID,D_MOVED_WHERE.D_MOVED_WHERE_KEY ASC) AS RowNum
                                         FROM D_MOVED_WHERE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_MOVED_WHERE;',
       		'COMPOSITE_KEY',
       		'RowNum, COMPOSITE_KEY, TB_PAM_UID, D_MOVED_WHERE_KEY',
       		1
       		),
       	(
       		'D_OUT_OF_CNTRY',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,D_OUT_OF_CNTRY_KEY) AS COMPOSITE_KEY ,  D_OUT_OF_CNTRY.*,
                                                ROW_NUMBER() OVER (ORDER BY D_OUT_OF_CNTRY.TB_PAM_UID, D_OUT_OF_CNTRY.D_OUT_OF_CNTRY_KEY ASC) AS RowNum
                                         FROM D_OUT_OF_CNTRY
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_OUT_OF_CNTRY;',
       		'COMPOSITE_KEY',
       		'RowNum, COMPOSITE_KEY, TB_PAM_UID, D_OUT_OF_CNTRY_KEY',
       		1
       		),
       	(
       		'D_PCR_SOURCE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CONVERT(VARCHAR,VAR_PAM_UID)+''_''+CONVERT(VARCHAR,D_PCR_SOURCE_KEY) AS COMPOSITE_KEY , D_PCR_SOURCE.*,
                                                ROW_NUMBER() OVER (ORDER BY D_PCR_SOURCE.VAR_PAM_UID,D_PCR_SOURCE.D_PCR_SOURCE_KEY ASC) AS RowNum
                                         FROM D_PCR_SOURCE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_PCR_SOURCE;',
       		'COMPOSITE_KEY',
       		'RowNum, COMPOSITE_KEY, VAR_PAM_UID, D_PCR_SOURCE_KEY',
       		1
       		),
       	(
       		'D_RASH_LOC_GE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CONVERT(VARCHAR,VAR_PAM_UID)+''_''+CONVERT(VARCHAR,D_RASH_LOC_GEN_KEY) AS COMPOSITE_KEY ,  D_RASH_LOC_GEN.*,
                                                ROW_NUMBER() OVER (ORDER BY D_RASH_LOC_GEN.VAR_PAM_UID,D_RASH_LOC_GEN.D_RASH_LOC_GEN_KEY ASC) AS RowNum
                                         FROM D_RASH_LOC_GEN
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_RASH_LOC_GEN;',
       		'COMPOSITE_KEY',
       		'RowNum, COMPOSITE_KEY, VAR_PAM_UID, D_RASH_LOC_GEN_KEY',
       		1
       		),
       	(
       		'D_SMR_EXAM_TY',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,D_SMR_EXAM_TY_KEY) AS COMPOSITE_KEY ,  D_SMR_EXAM_TY.*,
                                                ROW_NUMBER() OVER (ORDER BY D_SMR_EXAM_TY.TB_PAM_UID,D_SMR_EXAM_TY.D_SMR_EXAM_TY_KEY ASC) AS RowNum
                                         FROM D_SMR_EXAM_TY
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_SMR_EXAM_TY;',
       		'COMPOSITE_KEY',
       		'RowNum, COMPOSITE_KEY, TB_PAM_UID, D_SMR_EXAM_TY_KEY',
       		1
       		),
       	(
       		'LDF_HEPATITIS',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                                                        SELECT DISTINCT LDF_HEPATITIS.*,
                                                                               ROW_NUMBER() OVER (ORDER BY LDF_HEPATITIS.INVESTIGATION_KEY ASC) AS RowNum
                                                                        FROM LDF_HEPATITIS
                                                                     )
                                                                     SELECT *
                                                                     FROM PaginatedResults
                                                                     WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                                                     FROM LDF_HEPATITIS;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'F_TB_PAM',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT F_TB_PAM.*,
                                                ROW_NUMBER() OVER (ORDER BY F_TB_PAM.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM F_TB_PAM
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM F_TB_PAM;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'F_VAR_PAM',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT F_VAR_PAM.*,
                                                ROW_NUMBER() OVER (ORDER BY F_VAR_PAM.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM F_VAR_PAM
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM F_VAR_PAM;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'AGGREGATE_REPORT_DATAMART',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT AGGREGATE_REPORT_DATAMART.*,
                                                ROW_NUMBER() OVER (ORDER BY AGGREGATE_REPORT_DATAMART.REPORT_LOCAL_ID ASC) AS RowNum
                                         FROM AGGREGATE_REPORT_DATAMART
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM AGGREGATE_REPORT_DATAMART;',
       		'REPORT_LOCAL_ID',
       		'RowNum, REPORT_LOCAL_ID',
       		1
       		),
       	(
       		'Summary_Case_Group',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT Summary_Case_Group.*,
                                                ROW_NUMBER() OVER (ORDER BY Summary_Case_Group.SUMMARY_CASE_SRC_KEY ASC) AS RowNum
                                         FROM Summary_Case_Group
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM Summary_Case_Group;',
       		'SUMMARY_CASE_SRC_KEY',
       		'RowNum, SUMMARY_CASE_SRC_KEY',
       		1
       		),
       	(
       		'SUMMARY_REPORT_CASE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                                         SELECT DISTINCT SUMMARY_REPORT_CASE.*,
                                                                ROW_NUMBER() OVER (ORDER BY SUMMARY_REPORT_CASE.INVESTIGATION_KEY ASC) AS RowNum
                                                         FROM SUMMARY_REPORT_CASE
                                                      )
                                                      SELECT *
                                                      FROM PaginatedResults
                                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                                      FROM SUMMARY_REPORT_CASE;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'SR100',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT SR100.*,
                                                ROW_NUMBER() OVER (ORDER BY SR100.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM SR100
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM SR100;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'TB_DATAMART',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT TB_DATAMART.*,
                                                ROW_NUMBER() OVER (ORDER BY TB_DATAMART.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM TB_DATAMART
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM TB_DATAMART;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'TB_HIV_DATAMART',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT TB_HIV_DATAMART.*,
                                                ROW_NUMBER() OVER (ORDER BY TB_HIV_DATAMART.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM TB_HIV_DATAMART
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM TB_HIV_DATAMART;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'VAR_DATAMART',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT VAR_DATAMART.*,
                                                ROW_NUMBER() OVER (ORDER BY VAR_DATAMART.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM VAR_DATAMART
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM VAR_DATAMART;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'LDF_BMIRD',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LDF_BMIRD.*,
                                                ROW_NUMBER() OVER (ORDER BY LDF_BMIRD.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM LDF_BMIRD
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LDF_BMIRD;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'LDF_FOODBORNE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LDF_FOODBORNE.*,
                                                ROW_NUMBER() OVER (ORDER BY LDF_FOODBORNE.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM LDF_FOODBORNE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LDF_FOODBORNE;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'LDF_MUMPS',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LDF_MUMPS.*,
                                                ROW_NUMBER() OVER (ORDER BY LDF_MUMPS.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM LDF_MUMPS
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LDF_MUMPS;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'LDF_TETANUS',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LDF_TETANUS.*,
                                                ROW_NUMBER() OVER (ORDER BY LDF_TETANUS.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM LDF_TETANUS
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LDF_TETANUS;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'LDF_VACCINE_PREVENT_DISEASES',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LDF_VACCINE_PREVENT_DISEASES.*,
                                                ROW_NUMBER() OVER (ORDER BY LDF_VACCINE_PREVENT_DISEASES.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM LDF_VACCINE_PREVENT_DISEASES
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LDF_VACCINE_PREVENT_DISEASES;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'LDF_GENERIC',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LDF_GENERIC.*,
                                                ROW_NUMBER() OVER (ORDER BY LDF_GENERIC.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM LDF_GENERIC
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LDF_GENERIC;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'LDF_GENERIC2',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LDF_GENERIC2.*,
                                                ROW_NUMBER() OVER (ORDER BY LDF_GENERIC2.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM LDF_GENERIC2
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LDF_GENERIC2;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'D_LDF_META_DATA',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT D_LDF_META_DATA.*,
                                                ROW_NUMBER() OVER (ORDER BY D_LDF_META_DATA.ldf_uid ASC) AS RowNum
                                         FROM D_LDF_META_DATA
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_LDF_META_DATA;',
       		'ldf_uid',
       		'RowNum, ldf_uid',
       		1
       		),
       	(
       		'TB_PAM_LDF',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT TB_PAM_LDF.*,
                                                ROW_NUMBER() OVER (ORDER BY TB_PAM_LDF.TB_PAM_UID ASC) AS RowNum
                                         FROM TB_PAM_LDF
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM TB_PAM_LDF;',
       		'TB_PAM_UID',
       		'RowNum',
       		1
       		),
       	(
       		'VAR_PAM_LDF',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT VAR_PAM_LDF.*,
                                                ROW_NUMBER() OVER (ORDER BY VAR_PAM_LDF.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM VAR_PAM_LDF
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM VAR_PAM_LDF;',
       		'VAR_PAM_UID',
       		'RowNum VAR_PAM_UID',
       		1
       		),
       	(
       		'LDF_DATAMART_COLUMN_REF',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LDF_DATAMART_COLUMN_REF.*,
                                                ROW_NUMBER() OVER (ORDER BY LDF_DATAMART_COLUMN_REF.LDF_UID ASC) AS RowNum
                                         FROM LDF_DATAMART_COLUMN_REF
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LDF_DATAMART_COLUMN_REF;',
       		'LDF_UID',
       		'RowNum, LDF_UID',
       		1
       		),
       	(
       		'LDF_DATAMART_TABLE_REF',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT LDF_DATAMART_TABLE_REF.*,
                                                ROW_NUMBER() OVER (ORDER BY LDF_DATAMART_TABLE_REF.LDF_DATAMART_TABLE_REF_UID ASC) AS RowNum
                                         FROM LDF_DATAMART_TABLE_REF
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM LDF_DATAMART_TABLE_REF;',
       		'LDF_DATAMART_TABLE_REF_UID',
       		'RowNum, LDF_DATAMART_TABLE_REF_UID',
       		1
       		),
       	(
       		'D_CONTACT_RECORD',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT D_CONTACT_RECORD.*,
                                                ROW_NUMBER() OVER (ORDER BY D_CONTACT_RECORD.D_CONTACT_RECORD_KEY ASC) AS RowNum
                                         FROM D_CONTACT_RECORD
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM D_CONTACT_RECORD;',
       		'D_CONTACT_RECORD_KEY',
       		'RowNum, D_CONTACT_RECORD_KEY',
       		1
       		),
       	(
       		'DM_INV_ARBO_HUMA',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT DM_INV_ARBO_HUMAN.*,
                                                ROW_NUMBER() OVER (ORDER BY DM_INV_ARBO_HUMAN.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM DM_INV_ARBO_HUMAN
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM DM_INV_ARBO_HUMAN;',
       		'INVESTIGATION_KEY',
       		'RowNum,INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_C_AURIS',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT DM_INV_C_AURIS.*,
                                                ROW_NUMBER() OVER (ORDER BY DM_INV_C_AURIS.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM DM_INV_C_AURIS
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM DM_INV_C_AURIS;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_CONG_SYPHILIS',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT DM_INV_CONG_SYPHILIS.*,
                                                ROW_NUMBER() OVER (ORDER BY DM_INV_CONG_SYPHILIS.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM DM_INV_CONG_SYPHILIS
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM DM_INV_CONG_SYPHILIS;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_CP_CRE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT DM_INV_CP_CRE.*,
                                                ROW_NUMBER() OVER (ORDER BY DM_INV_CP_CRE.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM DM_INV_CP_CRE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM DM_INV_CP_CRE;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_GENERIC_V2',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT DM_INV_GENERIC_V2.*,
                                                ROW_NUMBER() OVER (ORDER BY DM_INV_GENERIC_V2.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM DM_INV_GENERIC_V2
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM DM_INV_GENERIC_V2;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_HEPATITIS_A_ACUTE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT DM_INV_HEPATITIS_A_ACUTE.*,
                                                ROW_NUMBER() OVER (ORDER BY DM_INV_HEPATITIS_A_ACUTE.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM DM_INV_HEPATITIS_A_ACUTE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM DM_INV_HEPATITIS_A_ACUTE;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_HEPATITIS_B_C_ACUTE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT DM_INV_HEPATITIS_B_C_ACUTE.*,
                                                ROW_NUMBER() OVER (ORDER BY DM_INV_HEPATITIS_B_C_ACUTE.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM DM_INV_HEPATITIS_B_C_ACUTE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM DM_INV_HEPATITIS_B_C_ACUTE;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_HEPATITIS_B_C_CHRONIC',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT DM_INV_HEPATITIS_B_C_CHRONIC.*,
                                                ROW_NUMBER() OVER (ORDER BY DM_INV_HEPATITIS_B_C_CHRONIC.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM DM_INV_HEPATITIS_B_C_CHRONIC
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM DM_INV_HEPATITIS_B_C_CHRONIC;',
       		'INVESTIGATION_KEY',
       		'RowNum,INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_HEPATITIS_B_PERINATAL',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT DM_INV_HEPATITIS_B_PERINATAL.*,
                                                ROW_NUMBER() OVER (ORDER BY DM_INV_HEPATITIS_B_PERINATAL.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM DM_INV_HEPATITIS_B_PERINATAL
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM DM_INV_HEPATITIS_B_PERINATAL;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_HEPATITIS_CORE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT DM_INV_HEPATITIS_CORE.*,
                                                ROW_NUMBER() OVER (ORDER BY DM_INV_HEPATITIS_CORE.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM DM_INV_HEPATITIS_CORE
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM DM_INV_HEPATITIS_CORE;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_HIV',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT DM_INV_HIV.*,
                                                ROW_NUMBER() OVER (ORDER BY DM_INV_HIV.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM DM_INV_HIV
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM DM_INV_HIV;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_MIS_COVID_19',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT DM_INV_MIS_COVID_19.*,
                                                ROW_NUMBER() OVER (ORDER BY DM_INV_MIS_COVID_19.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM DM_INV_MIS_COVID_19
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM DM_INV_MIS_COVID_19;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_STD',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                         SELECT DISTINCT DM_INV_STD.*,
                                                ROW_NUMBER() OVER (ORDER BY DM_INV_STD.INVESTIGATION_KEY ASC) AS RowNum
                                         FROM DM_INV_STD
                                      )
                                      SELECT *
                                      FROM PaginatedResults
                                      WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                      FROM DM_INV_STD;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'LDF_GENERIC1',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                                                                                                     SELECT DISTINCT LDF_GENERIC1.*,
                                                                                                            ROW_NUMBER() OVER (ORDER BY LDF_GENERIC1.INVESTIGATION_KEY ASC) AS RowNum
                                                                                                     FROM LDF_GENERIC1
                                                                                                  )
                                                                                                  SELECT *
                                                                                                  FROM PaginatedResults
                                                                                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                                                                                  FROM LDF_GENERIC1;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'COVID_CONTACT_DATAMART',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (                                              SELECT DISTINCT SRC_PATIENT_FIRST_NAME+''_''+ SRC_PATIENT_LAST_NAME + ''_''+CONVERT(VARCHAR,SRC_PATIENT_DOB) AS COMPOSITE_KEY, COVID_CONTACT_DATAMART.*,
                                                                       ROW_NUMBER() OVER (ORDER BY SRC_PATIENT_FIRST_NAME,SRC_PATIENT_LAST_NAME,SRC_PATIENT_DOB ASC) AS RowNum
                                                                FROM COVID_CONTACT_DATAMART
                                                             )
                                                             SELECT *
                                                             FROM PaginatedResults
                                                             WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                                                             FROM COVID_CONTACT_DATAMART;',
       		'COMPOSITE_KEY',
       		'RowNum, COMPOSITE_KEY',
       		1
       		),
        (
       		'COVID_LAB_CELR_DATAMART',
       		'RDB',
       		'RDB_MODERN',
       		' WITH PaginatedResults AS (
                  SELECT  DISTINCT Patient_ID +''_''+ +CONVERT(VARCHAR,Specimen_collection_date_time) + ''_'' + TESTING_LAB_ID
                  AS COMPOSITE_KEY, COVID_LAB_CELR_DATAMART.*,
                         ROW_NUMBER() OVER (ORDER BY COVID_LAB_CELR_DATAMART.Testing_lab_specimen_ID ASC) AS RowNum
                  FROM COVID_LAB_CELR_DATAMART
               )
               SELECT *
               FROM PaginatedResults
               WHERE RowNum BETWEEN :startRow AND :endRow;' ,
               'SELECT COUNT(*)
                  FROM COVID_LAB_CELR_DATAMART;'
               'COMPOSITE_KEY' ,
              'RowNum, COMPOSITE_KEY, File_created_date',
       		1
       		),
       	(
       		'GEOCODING_LOCATION',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
            SELECT DISTINCT GEOCODING_LOCATION.*,
                   ROW_NUMBER() OVER (ORDER BY GEOCODING_LOCATION.GEOCODING_LOCATION_KEY ASC) AS RowNum
            FROM GEOCODING_LOCATION
         )
         SELECT *
         FROM PaginatedResults
         WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
         FROM GEOCODING_LOCATION;',
       		'GEOCODING_LOCATION_KEY',
       		'RowNum, GEOCODING_LOCATION_KEY',
       		1
       		),
       	(
       		'Covid_Case_Datamart',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
            SELECT DISTINCT Covid_Case_Datamart.*,
                   ROW_NUMBER() OVER (ORDER BY Covid_Case_Datamart.COVID_CASE_DATAMART_KEY ASC) AS RowNum
            FROM Covid_Case_Datamart
         )
         SELECT *
         FROM PaginatedResults
         WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
         FROM Covid_Case_Datamart;',
       		'COVID_CASE_DATAMART_KEY',
       		'RowNum, COVID_CASE_DATAMART_KEY',
       		1
       		),
       	(
       		'Covid_lab_datamart',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
             SELECT DISTINCT Covid_lab_datamart.*,
                    ROW_NUMBER() OVER (ORDER BY Covid_lab_datamart.Covid_lab_datamart_key ASC) AS RowNum
             FROM Covid_lab_datamart
          )
          SELECT *
          FROM PaginatedResults
          WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
          FROM Covid_lab_datamart;',
       		'Covid_lab_datamart_KEY',
       		'RowNum, Covid_lab_datamart_KEY',
       		1
       		),
       	(
       		'Covid_Vaccination_datamart',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
            SELECT DISTINCT Covid_Vaccination_datamart.*,
                   ROW_NUMBER() OVER (ORDER BY Covid_Vaccination_datamart.Covid_Vaccination_datamart_KEY ASC) AS RowNum
            FROM Covid_Vaccination_datamart
         )
         SELECT *
         FROM PaginatedResults
         WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
         FROM Covid_Vaccination_datamart;',
       		'Covid_Vaccination_datamart_KEY',
       		'RowNum, Covid_Vaccination_datamart_KEY',
       		1
       		),
       	(
       		'DM_INV_ARBOVIRAL_CASES_MMG',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
            SELECT DISTINCT DM_INV_ARBOVIRAL_CASES_MMG.*,
                   ROW_NUMBER() OVER (ORDER BY DM_INV_ARBOVIRAL_CASES_MMG.INVESTIGATION_KEY ASC) AS RowNum
            FROM DM_INV_ARBOVIRAL_CASES_MMG
         )
         SELECT *
         FROM PaginatedResults
         WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
         FROM DM_INV_ARBOVIRAL_CASES_MMG;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_CM2',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
            SELECT DISTINCT DM_INV_CM2.*,
                   ROW_NUMBER() OVER (ORDER BY DM_INV_CM2.INVESTIGATION_KEY ASC) AS RowNum
            FROM DM_INV_CM2
         )
         SELECT *
         FROM PaginatedResults
         WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
         FROM DM_INV_CM2;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_CRH',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
           SELECT DISTINCT DM_INV_CRH.*,
         ROW_NUMBER() OVER (ORDER BY DM_INV_CRH.INVESTIGATION_KEY ASC) AS RowNum
           FROM DM_INV_CRH
         )
         SELECT *
         FROM PaginatedResults
         WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
         FROM DM_INV_CRH;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_FTP',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
          SELECT DISTINCT DM_INV_FTP.*,
               ROW_NUMBER() OVER (ORDER BY DM_INV_FTP.INVESTIGATION_KEY ASC) AS RowNum
          FROM DM_INV_FTP
         )
         SELECT *
         FROM PaginatedResults
         WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
         FROM DM_INV_FTP;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_NINE',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                      SELECT DISTINCT DM_INV_NINE.*,
               ROW_NUMBER() OVER (ORDER BY DM_INV_NINE.INVESTIGATION_KEY ASC) AS RowNum
                      FROM DM_INV_NINE
                   )
                   SELECT *
                   FROM PaginatedResults
                   WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                   FROM DM_INV_NINE;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_SAMP',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                      SELECT DISTINCT DM_INV_SAMP.*,
               ROW_NUMBER() OVER (ORDER BY DM_INV_SAMP.INVESTIGATION_KEY ASC) AS RowNum
                      FROM DM_INV_SAMP
                   )
                   SELECT *
                   FROM PaginatedResults
                   WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                   FROM DM_INV_SAMP;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_TB_DATAMART',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                      SELECT DISTINCT DM_INV_TB_DATAMART.*,
               ROW_NUMBER() OVER (ORDER BY DM_INV_TB_DATAMART.INVESTIGATION_KEY ASC) AS RowNum
                      FROM DM_INV_TB_DATAMART
                   )
                   SELECT *
                   FROM PaginatedResults
                   WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                   FROM DM_INV_TB_DATAMART;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		),
       	(
       		'DM_INV_UN',
       		'RDB',
       		'RDB_MODERN',
       		'WITH PaginatedResults AS (
                      SELECT DISTINCT DM_INV_UN.*,
                             ROW_NUMBER() OVER (ORDER BY DM_INV_UN.INVESTIGATION_KEY ASC) AS RowNum
                      FROM DM_INV_UN
                   )
                   SELECT *
                   FROM PaginatedResults
                   WHERE RowNum BETWEEN :startRow AND :endRow;',
       		'SELECT COUNT(*)
                   FROM DM_INV_UN;',
       		'INVESTIGATION_KEY',
       		'RowNum, INVESTIGATION_KEY',
       		1
       		)