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
       )