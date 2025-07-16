delete from Data_Compare_Config;

insert into Data_Compare_Config
(table_name, source_db, target_db, query, query_count, key_column_list, ignore_column_list, compare)
values
        (
            'D_PATIENT',
            'RDB',
            'RDB_MODERN',
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
            1
        ),
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
           'with PaginatedResults as (
                 select DISTINCT cm.CONFIRMATION_METHOD_CD as CONFIRMATION_METHOD_CD
                 ,i.case_uid as CASE_UID
                 ,i.inv_local_id as inv_local_id
                 ,ROW_NUMBER() OVER (ORDER BY i.case_uid ASC) AS RowNum
                 from confirmation_method_group cmg
                 inner join confirmation_method cm on cmg.CONFIRMATION_METHOD_KEY  = cm.CONFIRMATION_METHOD_KEY
                 inner join investigation i on i.INVESTIGATION_KEY = cmg.INVESTIGATION_KEY
                 )
                 SELECT *
                 FROM PaginatedResults
                 WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
           FROM CONFIRMATION_METHOD_GROUP;',
           'INV_LOCAL_ID',
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
           'RowNum, LDF_GROUP_KEY',
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
                        SELECT DISTINCT notfe.NOTIFICATION_KEY
                        , i.CASE_UID as CASE_UID
                        , notf.NOTIFICATION_LOCAL_ID as NOTIFICATION_LOCAL_ID
                        , notfe.NOTIFICATION_SENT_DT_KEY as NOTIFICATION_SENT_DT_KEY
                        , notfe.NOTIFICATION_SUBMIT_DT_KEY as NOTIFICATION_SUBMIT_DT_KEY
                        , notfe.COUNT as COUNT
                        , pat.PATIENT_UID as PATIENT_UID
                               , cd.CONDITION_CD as CONDITION_CD
                        , ROW_NUMBER() OVER (ORDER BY notfe.INVESTIGATION_KEY ASC) AS RowNum
                        FROM NOTIFICATION_EVENT notfe inner join NOTIFICATION notf on notf.NOTIFICATION_KEY  = notfe.NOTIFICATION_KEY
                        inner join INVESTIGATION i on i.INVESTIGATION_KEY  = notfe.INVESTIGATION_KEY
                        inner join D_PATIENT pat on notfe.PATIENT_KEY = pat.PATIENT_KEY
                               inner join CONDITION cd on cd.CONDITION_KEY = notfe.CONDITION_KEY
                        )
                        SELECT *
                        FROM PaginatedResults
                        WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                  FROM NOTIFICATION_EVENT;',
           'NOTIFICATION_LOCAL_ID',
           'RowNum , NOTIFICATION_KEY',
           1
       ),
       (
           'LDF_DATA',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                                     SELECT DISTINCT
                                             CONVERT(VARCHAR,ISNULL(LDF_GROUP.BUSINESS_OBJECT_UID, 1))+''_''+
                                             CONVERT(VARCHAR,ISNULL(LDF_DATA.LDF_COLUMN_TYPE, 1))+''_''+
                                             CONVERT(VARCHAR,ISNULL(LDF_DATA.CONDITION_CD, 1))+''_''+
                                             CONVERT(VARCHAR,ISNULL(LDF_DATA.CDC_NATIONAL_ID, 1))+''_''+
                                             CONVERT(VARCHAR,ISNULL(LDF_DATA.CLASS_CD, 1))+''_''+
                                             CONVERT(VARCHAR,ISNULL(LDF_DATA.CODE_SET_NM, 1))+''_''+
                                             CONVERT(VARCHAR,ISNULL(LDF_DATA.BUSINESS_OBJ_NM, 1))+''_''+
                                             CONVERT(VARCHAR,ISNULL(LDF_DATA.DISPLAY_ORDER_NUMBER, 1))+''_''+
                                             CONVERT(VARCHAR,ISNULL(LDF_DATA.IMPORT_VERSION_NBR, 1))+''_''+
                                             LOWER(CONVERT(VARCHAR(32), ISNULL(HASHBYTES(''MD5'', LDF_DATA.LABEL_TXT),1), 2)
                                      ) AS COMPOSITE_KEY,
                                      LDF_DATA.*,
                                      ROW_NUMBER() OVER (ORDER BY
                                             LDF_GROUP.BUSINESS_OBJECT_UID ASC,
                                             LDF_DATA.LDF_COLUMN_TYPE ASC,
                                             LDF_DATA.CONDITION_CD ASC,
                                             LDF_DATA.CDC_NATIONAL_ID ASC,
                                             LDF_DATA.CLASS_CD ASC,
                                             LDF_DATA.CODE_SET_NM ASC,
                                             LDF_DATA.BUSINESS_OBJ_NM ASC,
                                             LDF_DATA.DISPLAY_ORDER_NUMBER ASC,
                                             LDF_DATA.import_version_nbr ASC,
                                             LDF_DATA.LABEL_TXT ASC
                                      ) AS RowNum
                                      FROM LDF_DATA
                                      INNER JOIN LDF_GROUP ON LDF_GROUP.LDF_GROUP_KEY = LDF_DATA.LDF_GROUP_KEY
                                  )
                                  SELECT *
                                  FROM PaginatedResults
                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM LDF_DATA
                                  INNER JOIN LDF_GROUP ON LDF_GROUP.LDF_GROUP_KEY = LDF_DATA.LDF_GROUP_KEY;',
           'COMPOSITE_KEY',
           'RowNum, COMPOSITE_KEY, LDF_DATA_KEY, LDF_GROUP_KEY',
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
           'with PaginatedResults as (
                        SELECT distinct
                        INVESTIGATION.INV_LOCAL_ID  as INV_LOCAL_ID
                        ,CONDITION.CONDITION_CD as CONDITION_CD
                        ,PATIENT.PATIENT_UID as PATIENT_UID
                        ,HOSPITAL.ORGANIZATION_UID AS HOSPITAL_UID
                        ,REPORTERORG.ORGANIZATION_UID AS REPORTER_ORG_UID
                        ,PERSONREPORTER.PROVIDER_UID AS REPORTER_PROVIDER_UID
                        ,PROVIDER.PROVIDER_UID AS INVESTIGATOR_PROVIDER_UID
                        ,PHYSICIAN.PROVIDER_UID AS PHYSICIAN_PROVIDER_UID
                        ,L_INV_ADMINISTRATIVE.PAGE_CASE_UID AS ADMINISTRATIVE_PAGE_CASE_UID
                        ,L_INV_CLINICAL.PAGE_CASE_UID AS CLINICAL_PAGE_CASE_UID
                        ,L_INV_COMPLICATION.PAGE_CASE_UID AS COMPLICATION_PAGE_CASE_UID
                        ,L_INV_CONTACT.PAGE_CASE_UID AS CONTACT_PAGE_CASE_UID
                        ,L_INV_DEATH.PAGE_CASE_UID AS DEATH_PAGE_CASE_UID
                        ,L_INV_EPIDEMIOLOGY.PAGE_CASE_UID AS EPIDEMIOLOGY_PAGE_CASE_UID
                        ,L_INV_HIV.PAGE_CASE_UID AS HIV_PAGE_CASE_UID
                        ,L_INV_ISOLATE_TRACKING.PAGE_CASE_UID AS ISOLATE_TRACKING_PAGE_CASE_UID
                        ,L_INV_LAB_FINDING.PAGE_CASE_UID AS LAB_FINDING_PAGE_CASE_UID
                        ,L_INV_MEDICAL_HISTORY.PAGE_CASE_UID AS MEDICAL_HISTORY_PAGE_CASE_UID
                        ,L_INV_MOTHER.PAGE_CASE_UID AS MOTHER_PAGE_CASE_UID
                        ,L_INV_OTHER.PAGE_CASE_UID AS OTHER_PAGE_CASE_UID
                        ,L_INV_PATIENT_OBS.PAGE_CASE_UID AS PATIENT_OBS_PAGE_CASE_UID
                        ,L_INV_PREGNANCY_BIRTH.PAGE_CASE_UID AS PREGNANCY_BIRTH_PAGE_CASE_UID
                        ,L_INV_RESIDENCY.PAGE_CASE_UID AS RESIDENCY_PAGE_CASE_UID
                        ,L_INV_RISK_FACTOR.PAGE_CASE_UID AS RISK_FACTOR_PAGE_CASE_UID
                        ,L_INV_SOCIAL_HISTORY.PAGE_CASE_UID AS SOCIAL_HISTORY_PAGE_CASE_UID
                        ,L_INV_SYMPTOM.PAGE_CASE_UID AS SYMPTOM_PAGE_CASE_UID
                        ,L_INV_TRAVEL.PAGE_CASE_UID AS TRAVEL_PAGE_CASE_UID
                        ,L_INV_TREATMENT.PAGE_CASE_UID AS TREATMENT_PAGE_CASE_UID
                        ,L_INV_UNDER_CONDITION.PAGE_CASE_UID AS UNDER_CONDITION_PAGE_CASE_UID
                        ,L_INV_VACCINATION.PAGE_CASE_UID AS VACCINATION_PAGE_CASE_UID
                        ,L_INVESTIGATION_REPEAT.PAGE_CASE_UID AS INVESTIGATION_REPEAT_PAGE_CASE_UID
                        ,L_INV_PLACE_REPEAT.PAGE_CASE_UID AS PLACE_REPEAT_PAGE_CASE_UID
                        ,ROW_NUMBER() OVER (ORDER BY INVESTIGATION.INV_LOCAL_ID ASC) AS RowNum
                        FROM F_PAGE_CASE  FSIV
                        LEFT OUTER JOIN D_PATIENT PATIENT WITH (NOLOCK) ON	FSIV.PATIENT_KEY= PATIENT.PATIENT_KEY
                        LEFT OUTER JOIN D_ORGANIZATION  HOSPITAL WITH (NOLOCK) ON 	FSIV.HOSPITAL_KEY= HOSPITAL.ORGANIZATION_KEY
                        LEFT OUTER JOIN D_ORGANIZATION REPORTERORG WITH (NOLOCK) ON 	FSIV.ORG_AS_REPORTER_KEY= REPORTERORG.ORGANIZATION_KEY
                        LEFT OUTER JOIN D_PROVIDER PERSONREPORTER WITH (NOLOCK) ON  	FSIV.PERSON_AS_REPORTER_KEY= PERSONREPORTER.PROVIDER_KEY
                        LEFT OUTER JOIN D_PROVIDER PROVIDER WITH (NOLOCK) ON 	FSIV.INVESTIGATOR_KEY= PROVIDER.PROVIDER_KEY
                        LEFT OUTER JOIN D_PROVIDER PHYSICIAN WITH (NOLOCK) ON 	FSIV.PHYSICIAN_KEY= PHYSICIAN.PROVIDER_KEY
                        INNER JOIN INVESTIGATION  INVESTIGATION WITH (NOLOCK) ON 	FSIV.INVESTIGATION_KEY= INVESTIGATION.INVESTIGATION_KEY
                        LEFT OUTER JOIN CONDITION CONDITION WITH (NOLOCK) ON 	FSIV.CONDITION_KEY= CONDITION.CONDITION_KEY
                        LEFT OUTER JOIN   L_INV_ADMINISTRATIVE with (nolock) ON  L_INV_ADMINISTRATIVE.D_INV_ADMINISTRATIVE_KEY  =  FSIV.D_INV_ADMINISTRATIVE_KEY
                        LEFT OUTER JOIN   L_INV_CLINICAL with (nolock) ON  L_INV_CLINICAL.D_INV_CLINICAL_KEY  =  FSIV.D_INV_CLINICAL_KEY
                        LEFT OUTER JOIN   L_INV_COMPLICATION with (nolock) ON L_INV_COMPLICATION.D_INV_COMPLICATION_KEY  =  FSIV.D_INV_COMPLICATION_KEY
                        LEFT OUTER JOIN   L_INV_CONTACT with (nolock) ON L_INV_CONTACT.D_INV_CONTACT_KEY  =  FSIV.D_INV_CONTACT_KEY
                        LEFT OUTER JOIN   L_INV_DEATH with (nolock) ON L_INV_DEATH.D_INV_DEATH_KEY  =  FSIV.D_INV_DEATH_KEY
                        LEFT OUTER JOIN   L_INV_EPIDEMIOLOGY with (nolock) ON L_INV_EPIDEMIOLOGY.D_INV_EPIDEMIOLOGY_KEY  =  FSIV.D_INV_EPIDEMIOLOGY_KEY
                        LEFT OUTER JOIN   L_INV_HIV with (nolock) ON L_INV_HIV.D_INV_HIV_KEY  =  FSIV.D_INV_HIV_KEY
                        LEFT OUTER JOIN   L_INV_ISOLATE_TRACKING with (nolock) ON L_INV_ISOLATE_TRACKING.D_INV_ISOLATE_TRACKING_KEY  =  FSIV.D_INV_ISOLATE_TRACKING_KEY
                        LEFT OUTER JOIN   L_INV_LAB_FINDING with (nolock) ON L_INV_LAB_FINDING.D_INV_LAB_FINDING_KEY  =  FSIV.D_INV_LAB_FINDING_KEY
                        LEFT OUTER JOIN   L_INV_MEDICAL_HISTORY with (nolock) ON L_INV_MEDICAL_HISTORY.D_INV_MEDICAL_HISTORY_KEY  =  FSIV.D_INV_MEDICAL_HISTORY_KEY
                        LEFT OUTER JOIN   L_INV_MOTHER with (nolock) ON L_INV_MOTHER.D_INV_MOTHER_KEY  =  FSIV.D_INV_MOTHER_KEY
                        LEFT OUTER JOIN   L_INV_OTHER with (nolock) ON L_INV_OTHER.D_INV_OTHER_KEY  =  FSIV.D_INV_OTHER_KEY
                        LEFT OUTER JOIN   L_INV_PATIENT_OBS with (nolock) ON L_INV_PATIENT_OBS.D_INV_PATIENT_OBS_KEY  =  FSIV.D_INV_PATIENT_OBS_KEY
                        LEFT OUTER JOIN   L_INV_PREGNANCY_BIRTH with (nolock) ON L_INV_PREGNANCY_BIRTH.D_INV_PREGNANCY_BIRTH_KEY  =  FSIV.D_INV_PREGNANCY_BIRTH_KEY
                        LEFT OUTER JOIN   L_INV_RESIDENCY with (nolock) ON L_INV_RESIDENCY.D_INV_RESIDENCY_KEY  =  FSIV.D_INV_RESIDENCY_KEY
                        LEFT OUTER JOIN   L_INV_RISK_FACTOR with (nolock) ON L_INV_RISK_FACTOR.D_INV_RISK_FACTOR_KEY  =  FSIV.D_INV_RISK_FACTOR_KEY
                        LEFT OUTER JOIN   L_INV_SOCIAL_HISTORY with (nolock) ON L_INV_SOCIAL_HISTORY.D_INV_SOCIAL_HISTORY_KEY  =  FSIV.D_INV_SOCIAL_HISTORY_KEY
                        LEFT OUTER JOIN   L_INV_SYMPTOM with (nolock) ON  L_INV_SYMPTOM.D_INV_SYMPTOM_KEY  =  FSIV.D_INV_SYMPTOM_KEY
                        LEFT OUTER JOIN   L_INV_TRAVEL with (nolock) ON  L_INV_TRAVEL.D_INV_TRAVEL_KEY  =  FSIV.D_INV_TRAVEL_KEY
                        LEFT OUTER JOIN   L_INV_TREATMENT with (nolock) ON  L_INV_TREATMENT.D_INV_TREATMENT_KEY  =  FSIV.D_INV_TREATMENT_KEY
                        LEFT OUTER JOIN   L_INV_UNDER_CONDITION with (nolock) ON  L_INV_UNDER_CONDITION.D_INV_UNDER_CONDITION_KEY  =  FSIV.D_INV_UNDER_CONDITION_KEY
                        LEFT OUTER JOIN   L_INV_VACCINATION with (nolock) ON  L_INV_VACCINATION.D_INV_VACCINATION_KEY  =  FSIV.D_INV_VACCINATION_KEY
                        LEFT OUTER JOIN   L_INVESTIGATION_REPEAT with (nolock) ON  L_INVESTIGATION_REPEAT.D_INVESTIGATION_REPEAT_KEY  =  FSIV.D_INVESTIGATION_REPEAT_KEY
                        LEFT OUTER JOIN   L_INV_PLACE_REPEAT with (nolock) ON  L_INV_PLACE_REPEAT.D_INV_PLACE_REPEAT_KEY  =  FSIV.D_INV_PLACE_REPEAT_KEY
                        )
                        SELECT *
                        FROM PaginatedResults
                        WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM F_PAGE_CASE;',
           'INV_LOCAL_ID',
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
       (
           'LAB_TEST_RESULT',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                        SELECT
                               LAB_TEST_UID,
                               INVESTIGATION.CASE_UID,
                               DORG1.ORGANIZATION_UID AS PERFORMING_LAB_UID,
                               DORG2.ORGANIZATION_UID AS ORDERING_ORG_UID,
                               DORG3.ORGANIZATION_UID AS REPORTING_LAB_UID,
                               DT1.DATE_MM_DD_YYYY AS LAB_RPT_DT,
                               CD.CONDITION_DESC,
                               PT.PATIENT_UID,
                               DPRO1.PROVIDER_UID AS COPY_TO_PROVIDER_UID,
                               DPRO2.PROVIDER_UID AS LAB_TEST_TECHNICIAN_UID,
                               DPRO3.PROVIDER_UID AS SPECIMEN_COLLECTOR_UID,
                               DPRO4.PROVIDER_UID AS ORDERING_PROVIDER_UID,
                               MORBIDITY_REPORT.MORB_RPT_UID,
                               LG.BUSINESS_OBJECT_UID,
                        ROW_NUMBER() OVER (ORDER BY LAB_TEST_RESULT.LAB_TEST_KEY ASC) AS RowNum
                        FROM LAB_TEST_RESULT
                        LEFT JOIN INVESTIGATION ON INVESTIGATION.INVESTIGATION_KEY = LAB_TEST_RESULT.INVESTIGATION_KEY
                        LEFT JOIN D_ORGANIZATION DORG1 WITH(NOLOCK) ON LAB_TEST_RESULT.PERFORMING_LAB_KEY = DORG1.ORGANIZATION_KEY
                        LEFT JOIN D_ORGANIZATION DORG2 WITH(NOLOCK) ON LAB_TEST_RESULT.ORDERING_ORG_KEY = DORG2.ORGANIZATION_KEY
                        LEFT JOIN D_ORGANIZATION DORG3 WITH(NOLOCK) ON LAB_TEST_RESULT.REPORTING_LAB_KEY = DORG3.ORGANIZATION_KEY
                        LEFT JOIN RDB_DATE DT1 WITH(NOLOCK) ON DT1.DATE_KEY = LAB_TEST_RESULT.LAB_RPT_DT_KEY
                        LEFT JOIN CONDITION CD ON CD.CONDITION_KEY = LAB_TEST_RESULT.CONDITION_KEY
                        LEFT JOIN D_PATIENT PT ON PT.PATIENT_KEY = LAB_TEST_RESULT.PATIENT_KEY
                        LEFT JOIN D_PROVIDER DPRO1 WITH(NOLOCK) ON LAB_TEST_RESULT.COPY_TO_PROVIDER_KEY  = DPRO1.PROVIDER_KEY
                        LEFT JOIN D_PROVIDER DPRO2 WITH(NOLOCK) ON LAB_TEST_RESULT.LAB_TEST_TECHNICIAN_KEY  = DPRO2.PROVIDER_KEY
                        LEFT JOIN D_PROVIDER DPRO3 WITH(NOLOCK) ON LAB_TEST_RESULT.SPECIMEN_COLLECTOR_KEY  = DPRO3.PROVIDER_KEY
                        LEFT JOIN D_PROVIDER DPRO4 WITH(NOLOCK) ON LAB_TEST_RESULT.ORDERING_PROVIDER_KEY  = DPRO4.PROVIDER_KEY
                        LEFT JOIN LDF_GROUP LG WITH(NOLOCK) ON LG.LDF_GROUP_KEY = LAB_TEST_RESULT.LDF_GROUP_KEY
                        LEFT JOIN MORBIDITY_REPORT ON MORBIDITY_REPORT.MORB_RPT_KEY = LAB_TEST_RESULT.MORB_RPT_KEY
                        )
                        SELECT *
                        FROM PaginatedResults
                        WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM LAB_TEST_RESULT;',
           'LAB_TEST_UID',
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
           'RowNum, LAB_TEST_UID, LAB_RESULT_COMMENT_KEY, RESULT_COMMENT_GRP_KEY, RDB_LAST_REFRESH_TIME',
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
           'RowNum, LAB_TEST_UID, TEST_RESULT_GRP_KEY, TEST_RESULT_VAL_KEY, RDB_LAST_REFRESH_TIME',
           1
       ),
       (
           'LAB100',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                                     SELECT DISTINCT LAB100.LAB_RPT_LOCAL_ID+''_''+CONVERT(VARCHAR, LAB_TEST.LAB_TEST_UID) AS COMPOSITE_KEY, LAB100.*,
                                             ROW_NUMBER() OVER (ORDER BY LAB100.LAB_RPT_LOCAL_ID ASC, lab_test.lab_test_uid ASC) AS RowNum
                                      FROM LAB100
                                      INNER JOIN LAB_TEST
                                             ON LAB_TEST.LAB_TEST_KEY = LAB100.RESULTED_LAB_TEST_KEY
                                             AND LAB_TEST.LAB_RPT_LOCAL_ID = LAB100.LAB_RPT_LOCAL_ID
                                  )
                                  SELECT *
                                  FROM PaginatedResults
                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM LAB100
                                  INNER JOIN LAB_TEST
                                             ON LAB_TEST.LAB_TEST_KEY = LAB100.RESULTED_LAB_TEST_KEY
                                             AND LAB_TEST.LAB_RPT_LOCAL_ID = LAB100.LAB_RPT_LOCAL_ID;',
           'COMPOSITE_KEY',
           'RowNum, COMPOSITE_KEY, LAB_RPT_LOCAL_ID, PATIENT_KEY, RESULTED_LAB_TEST_KEY, MORB_RPT_KEY, INVESTIGATION_KEYS, LDF_GROUP_KEY, RDB_LAST_REFRESH_TIME',
           1
       ),
       (
           'LAB101',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                                     SELECT DISTINCT LAB101.LAB_RPT_LOCAL_ID+''_''+CONVERT(VARCHAR, LAB_TEST.LAB_TEST_UID) AS COMPOSITE_KEY, LAB101.*,
                                             ROW_NUMBER() OVER (ORDER BY LAB101.LAB_RPT_LOCAL_ID ASC, LAB_TEST.LAB_TEST_UID ASC) AS RowNum
                                      FROM LAB101
                                      INNER JOIN LAB_TEST
                                             ON LAB_TEST.LAB_TEST_KEY = LAB101.RESULTED_LAB_TEST_KEY
                                             AND LAB_TEST.LAB_RPT_LOCAL_ID = LAB101.LAB_RPT_LOCAL_ID
                                  )
                                  SELECT *
                                  FROM PaginatedResults
                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM LAB101
                                  INNER JOIN LAB_TEST
                                      ON LAB_TEST.LAB_TEST_KEY = LAB101.RESULTED_LAB_TEST_KEY
                                      AND LAB_TEST.LAB_RPT_LOCAL_ID = LAB101.LAB_RPT_LOCAL_ID;',
           'COMPOSITE_KEY',
           'RowNum, LAB_RPT_LOCAL_ID, RESULTED_LAB_TEST_KEY, RDB_LAST_REFRESH_TIME',
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
           'DECLARE @sql NVARCHAR(MAX)
                        DECLARE @startRow INT = :startRow
                        DECLARE @endRow INT = :endRow
                        IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''nrt_case_management'' AND type = ''U'')
                        BEGIN
                        SET @sql = ''
                               ;WITH PaginatedResults AS (
                               SELECT
                                      m.*,
                                      a.public_health_case_uid AS case_management_uid,
                                      ROW_NUMBER() OVER (ORDER BY m.D_CASE_MANAGEMENT_KEY) AS RowNum
                               FROM nrt_case_management a
                               JOIN D_CASE_MANAGEMENT m ON a.D_CASE_MANAGEMENT_KEY = m.D_CASE_MANAGEMENT_KEY
                               )
                               SELECT *
                               FROM PaginatedResults
                               WHERE RowNum BETWEEN @startRow AND @endRow
                        ''
                        END
                        ELSE
                        BEGIN
                        SET @sql = ''
                               ;WITH PaginatedResults AS (
                               SELECT
                                      m.*,
                                      a.case_management_uid AS case_management_uid,
                                      ROW_NUMBER() OVER (ORDER BY m.D_CASE_MANAGEMENT_KEY) AS RowNum
                               FROM L_CASE_MANAGEMENT a
                               JOIN D_CASE_MANAGEMENT m ON a.D_CASE_MANAGEMENT_KEY = m.D_CASE_MANAGEMENT_KEY
                               )
                               SELECT *
                               FROM PaginatedResults
                               WHERE RowNum BETWEEN @startRow AND @endRow
                        ''
                        END
                        EXEC sp_executesql @sql, N''@startRow INT, @endRow INT'', @startRow=@startRow, @endRow=@endRow;',
           'SELECT COUNT(*)
                                  FROM D_CASE_MANAGEMENT;',
           'case_management_uid',
           'RowNum, INVESTIGATION_KEY',
           1
       ),
       (
           'CASE_COUNT',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                        select
                        i.case_uid
                        , cc.case_count
                        , cc.INVESTIGATION_COUNT
                        , cd.CONDITION_CD
                        , pt.patient_uid
                        , dpro1.provider_uid as investigator_uid
                        , dpro2.provider_uid as physician_uid
                        , dpro3.provider_uid as reporter_uid
                        , dorg1.ORGANIZATION_UID as ORGANIZATION_UID
                        , dorg2.ORGANIZATION_UID as hospital_uid
                        , cc.Inv_Assigned_dt_key as Inv_Assigned_dt_key
                        , cc.INV_START_DT_KEY as INV_START_DT_KEY
                        , cc.DIAGNOSIS_DT_KEY as DIAGNOSIS_DT_KEY
                        , cc.INV_RPT_DT_KEY as INV_RPT_DT_KEY
                        , ROW_NUMBER() OVER (ORDER BY i.case_uid ASC) AS RowNum
                        from CASE_COUNT cc
                        inner join INVESTIGATION i on cc.investigation_key = i.investigation_key
                        inner join CONDITION cd on cd.CONDITION_KEY = cc.CONDITION_KEY
                        inner join D_PATIENT pt on pt.patient_key = cc.patient_key
                        inner join D_PROVIDER dpro1 with(nolock) on cc.INVESTIGATOR_KEY  = dpro1.PROVIDER_KEY
                        inner join D_PROVIDER dpro2 with(nolock) on cc.PHYSICIAN_KEY  = dpro2.PROVIDER_KEY
                        inner join D_PROVIDER dpro3 with(nolock) on cc.REPORTER_KEY  = dpro3.PROVIDER_KEY
                        inner join D_ORGANIZATION dorg1 with(nolock) on cc.Rpt_Src_Org_key = dorg1.ORGANIZATION_KEY
                        inner join D_ORGANIZATION dorg2 with(nolock) on cc.ADT_HSPTL_KEY = dorg2.ORGANIZATION_KEY
                        )
                        SELECT *
                        FROM PaginatedResults
                        WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM CASE_COUNT;',
           'CASE_UID',
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
                        SELECT
                        shd.ADI_900_STATUS
                        ,shd.ADI_900_STATUS_CD
                        ,shd.ADM_REFERRAL_BASIS_OOJ
                        ,shd.ADM_RPTNG_CNTY
                        ,shd.CA_INIT_INTVWR_ASSGN_DT
                        ,shd.CA_INTERVIEWER_ASSIGN_DT
                        ,shd.CA_PATIENT_INTV_STATUS
                        ,shd.CALC_5_YEAR_AGE_GROUP
                        ,shd.CASE_RPT_MMWR_WK
                        ,shd.CASE_RPT_MMWR_YR
                        ,shd.CC_CLOSED_DT
                        ,shd.CLN_CARE_STATUS_CLOSE_DT
                        ,shd.CLN_CONDITION_RESISTANT_TO
                        ,shd.CLN_DT_INIT_HLTH_EXM
                        ,shd.CLN_NEUROSYPHILLIS_IND
                        ,shd.CLN_PRE_EXP_PROPHY_IND
                        ,shd.CLN_PRE_EXP_PROPHY_REFER
                        ,shd.CLN_SURV_PROVIDER_DIAG_CD
                        ,shd.CMP_CONJUNCTIVITIS_IND
                        ,shd.CMP_PID_IND
                        ,shd.COINFECTION_ID
                        ,shd.CONDITION_CD
                        ,shd.CONFIRMATION_DT
                        ,shd.CURR_PROCESS_STATE
                        ,shd.DETECTION_METHOD_DESC_TXT
                        ,shd.DIAGNOSIS
                        ,shd.DIAGNOSIS_CD
                        ,shd.DIE_FRM_THIS_ILLNESS_IND
                        ,shd.DISEASE_IMPORTED_IND
                        ,shd.DISSEMINATED_IND
                        ,shd.EPI_CNTRY_USUAL_RESID
                        ,shd.EPI_LINK_ID
                        ,shd.FIELD_RECORD_NUMBER
                        ,shd.FL_FUP_ACTUAL_REF_TYPE
                        ,shd.FL_FUP_DISPO_DT
                        ,shd.FL_FUP_DISPOSITION
                        ,shd.FL_FUP_EXAM_DT
                        ,shd.FL_FUP_EXPECTED_DT
                        ,shd.FL_FUP_EXPECTED_IN_IND_CD
                        ,shd.FL_FUP_INIT_ASSGN_DT
                        ,shd.FL_FUP_INTERNET_OUTCOME_CD
                        ,shd.FL_FUP_INVESTIGATOR_ASSGN_DT
                        ,shd.FL_FUP_NOTIFICATION_PLAN
                        ,shd.FL_FUP_OOJ_OUTCOME
                        ,shd.FL_FUP_PROV_DIAGNOSIS_CD
                        ,shd.FL_FUP_PROV_EXM_REASON
                        ,shd.HIV_900_RESULT
                        ,shd.HIV_900_TEST_IND
                        ,shd.HIV_900_TEST_REFERRAL_DT
                        ,shd.HIV_AV_THERAPY_EVER_IND
                        ,shd.HIV_AV_THERAPY_LAST_12MO_IND
                        ,shd.HIV_CA_900_OTH_RSN_NOT_LO
                        ,shd.HIV_CA_900_REASON_NOT_LOC
                        ,shd.HIV_ENROLL_PRTNR_SRVCS_IND
                        ,shd.HIV_KEEP_900_CARE_APPT_IND
                        ,shd.HIV_LAST_900_TEST_DT
                        ,shd.HIV_POST_TEST_900_COUNSELING
                        ,shd.HIV_PREVIOUS_900_TEST_IND
                        ,shd.HIV_REFER_FOR_900_CARE_IND
                        ,shd.HIV_REFER_FOR_900_TEST
                        ,shd.HIV_RST_PROVIDED_900_RSLT_IND
                        ,shd.HIV_SELF_REPORTED_RSLT_900
                        ,shd.HIV_STATE_CASE_ID
                        ,shd.HSPTLIZD_IND
                        ,shd.INIT_FUP_CLINIC_CODE
                        ,shd.INIT_FUP_CLOSED_DT
                        ,shd.INIT_FUP_INITIAL_FOLL_UP
                        ,shd.INIT_FUP_INTERNET_FOLL_UP
                        ,shd.INIT_FUP_INITIAL_FOLL_UP_CD
                        ,shd.INIT_FUP_INTERNET_FOLL_UP_CD
                        ,shd.INIT_FUP_NOTIFIABLE
                        ,shd.INITIATING_AGNCY
                        ,shd.INV_ASSIGNED_DT
                        ,shd.INV_CASE_STATUS
                        ,shd.INV_CLOSE_DT
                        ,shd.INV_LOCAL_ID
                        ,shd.INV_RPT_DT
                        ,shd.INV_START_DT
                        ,shd.INVESTIGATION_DEATH_DATE
                        ,shd.INVESTIGATION_STATUS
                        ,shd.INVESTIGATOR_CLOSED_QC
                        ,shd.INVESTIGATOR_CURRENT_QC
                        ,shd.INVESTIGATOR_DISP_FL_FUP_QC
                        ,shd.INVESTIGATOR_FL_FUP_QC
                        ,shd.INVESTIGATOR_INIT_INTRVW_QC
                        ,shd.INVESTIGATOR_INIT_FL_FUP_QC
                        ,shd.INVESTIGATOR_INITIAL_QC
                        ,shd.INVESTIGATOR_INTERVIEW_QC
                        ,shd.INVESTIGATOR_SUPER_CASE_QC
                        ,shd.INVESTIGATOR_SUPER_FL_FUP_QC
                        ,shd.INVESTIGATOR_SURV_QC
                        ,shd.IPO_CURRENTLY_IN_INSTITUTION
                        ,shd.IPO_LIVING_WITH
                        ,shd.IPO_NAME_OF_INSTITUTITION
                        ,shd.IPO_TIME_AT_ADDRESS_NUM
                        ,shd.IPO_TIME_AT_ADDRESS_UNIT
                        ,shd.IPO_TIME_IN_COUNTRY_NUM
                        ,shd.IPO_TIME_IN_COUNTRY_UNIT
                        ,shd.IPO_TIME_IN_STATE_NUM
                        ,shd.IPO_TIME_IN_STATE_UNIT
                        ,shd.IPO_TYPE_OF_INSTITUTITION
                        ,shd.IPO_TYPE_OF_RESIDENCE
                        ,shd.IX_DATE_OI
                        ,shd.JURISDICTION_CD
                        ,shd.JURISDICTION_NM
                        ,shd.LAB_HIV_SPECIMEN_COLL_DT
                        ,shd.LAB_NONTREP_SYPH_RSLT_QNT
                        ,shd.LAB_NONTREP_SYPH_RSLT_QUA
                        ,shd.LAB_NONTREP_SYPH_TEST_TYP
                        ,shd.LAB_SYPHILIS_TST_PS_IND
                        ,shd.LAB_SYPHILIS_TST_RSLT_PS
                        ,shd.LAB_TESTS_PERFORMED
                        ,shd.LAB_TREP_SYPH_RESULT_QUAL
                        ,shd.LAB_TREP_SYPH_TEST_TYPE
                        ,shd.MDH_PREV_STD_HIST
                        ,shd.OOJ_AGENCY_SENT_TO
                        ,shd.OOJ_DUE_DATE_SENT_TO
                        ,shd.OOJ_FR_NUMBER_SENT_TO
                        ,shd.OOJ_INITG_AGNCY_OUTC_DUE_DATE
                        ,shd.OOJ_INITG_AGNCY_OUTC_SNT_DATE
                        ,shd.OOJ_INITG_AGNCY_RECD_DATE
                        ,shd.OUTBREAK_IND
                        ,shd.OUTBREAK_NAME
                        ,shd.PATIENT_ADDL_GENDER_INFO
                        ,shd.PATIENT_AGE_AT_ONSET
                        ,shd.PATIENT_AGE_AT_ONSET_UNIT
                        ,shd.PATIENT_AGE_REPORTED
                        ,shd.PATIENT_ALIAS
                        ,shd.PATIENT_BIRTH_COUNTRY
                        ,shd.PATIENT_BIRTH_SEX
                        ,shd.PATIENT_CENSUS_TRACT
                        ,shd.PATIENT_CITY
                        ,shd.PATIENT_COUNTRY
                        ,shd.PATIENT_COUNTY
                        ,shd.PATIENT_CURR_SEX_UNK_RSN
                        ,shd.PATIENT_CURRENT_SEX
                        ,shd.PATIENT_DECEASED_DATE
                        ,shd.PATIENT_DECEASED_INDICATOR
                        ,shd.PATIENT_DOB
                        ,shd.PATIENT_EMAIL
                        ,shd.PATIENT_ETHNICITY
                        ,shd.PATIENT_LOCAL_ID
                        ,shd.PATIENT_MARITAL_STATUS
                        ,shd.PATIENT_NAME
                        ,shd.PATIENT_PHONE_CELL
                        ,shd.PATIENT_PHONE_HOME
                        ,shd.PATIENT_PHONE_WORK
                        ,shd.PATIENT_PREFERRED_GENDER
                        ,shd.PATIENT_PREGNANT_IND
                        ,shd.PATIENT_RACE
                        ,shd.PATIENT_SEX
                        ,shd.PATIENT_STATE
                        ,shd.PATIENT_STREET_ADDRESS_1
                        ,shd.PATIENT_STREET_ADDRESS_2
                        ,shd.PATIENT_UNK_ETHNIC_RSN
                        ,shd.PATIENT_ZIP
                        ,shd.PBI_IN_PRENATAL_CARE_IND
                        ,shd.PBI_PATIENT_PREGNANT_WKS
                        ,shd.PBI_PREG_AT_EXAM_IND
                        ,shd.PBI_PREG_AT_EXAM_WKS
                        ,shd.PBI_PREG_AT_IX_IND
                        ,shd.PBI_PREG_AT_IX_WKS
                        ,shd.PBI_PREG_IN_LAST_12MO_IND
                        ,shd.PBI_PREG_OUTCOME
                        ,shd.PROGRAM_AREA_CD
                        ,shd.PROGRAM_JURISDICTION_OID
                        ,shd.RPT_ELICIT_INTERNET_INFO
                        ,shd.RPT_FIRST_NDLSHARE_EXP_DT
                        ,shd.RPT_FIRST_SEX_EXP_DT
                        ,shd.RPT_LAST_NDLSHARE_EXP_DT
                        ,shd.PROVIDER_REASON_VISIT_DT
                        ,shd.REFERRAL_BASIS
                        ,shd.RPT_LAST_SEX_EXP_DT
                        ,shd.RPT_MET_OP_INTERNET
                        ,shd.RPT_NDLSHARE_EXP_FREQ
                        ,shd.RPT_RELATIONSHIP_TO_OP
                        ,shd.RPT_SEX_EXP_FREQ
                        ,shd.RPT_SRC_CD_DESC
                        ,shd.RPT_SPOUSE_OF_OP
                        ,shd.RSK_BEEN_INCARCERATD_12MO_IND
                        ,shd.RSK_COCAINE_USE_12MO_IND
                        ,shd.RSK_CRACK_USE_12MO_IND
                        ,shd.RSK_ED_MEDS_USE_12MO_IND
                        ,shd.RSK_HEROIN_USE_12MO_IND
                        ,shd.RSK_INJ_DRUG_USE_12MO_IND
                        ,shd.RSK_METH_USE_12MO_IND
                        ,shd.RSK_NITR_POP_USE_12MO_IND
                        ,shd.RSK_NO_DRUG_USE_12MO_IND
                        ,shd.RSK_OTHER_DRUG_SPEC
                        ,shd.RSK_OTHER_DRUG_USE_12MO_IND
                        ,shd.RSK_RISK_FACTORS_ASSESS_IND
                        ,shd.RSK_SEX_EXCH_DRGS_MNY_12MO_IND
                        ,shd.RSK_SEX_INTOXCTED_HGH_12MO_IND
                        ,shd.RSK_SEX_W_ANON_PTRNR_12MO_IND
                        ,shd.RSK_SEX_W_FEMALE_12MO_IND
                        ,shd.RSK_SEX_W_KNOWN_IDU_12MO_IND
                        ,shd.RSK_SEX_W_KNWN_MSM_12M_FML_IND
                        ,shd.RSK_SEX_W_MALE_12MO_IND
                        ,shd.RSK_SEX_W_TRANSGNDR_12MO_IND
                        ,shd.RSK_SEX_WOUT_CONDOM_12MO_IND
                        ,shd.RSK_SHARED_INJ_EQUIP_12MO_IND
                        ,shd.RSK_TARGET_POPULATIONS
                        ,shd.SOC_FEMALE_PRTNRS_12MO_IND
                        ,shd.SOC_FEMALE_PRTNRS_12MO_TTL
                        ,shd.SOC_MALE_PRTNRS_12MO_IND
                        ,shd.SOC_MALE_PRTNRS_12MO_TOTAL
                        ,shd.SOC_PLACES_TO_HAVE_SEX
                        ,shd.SOC_PLACES_TO_MEET_PARTNER
                        ,shd.SOC_PRTNRS_PRD_FML_IND
                        ,shd.SOC_PRTNRS_PRD_FML_TTL
                        ,shd.SOC_PRTNRS_PRD_MALE_IND
                        ,shd.SOC_PRTNRS_PRD_MALE_TTL
                        ,shd.SOC_PRTNRS_PRD_TRNSGNDR_IND
                        ,shd.SOC_SX_PRTNRS_INTNT_12MO_IND
                        ,shd.SOC_TRANSGNDR_PRTNRS_12MO_IND
                        ,shd.SOC_TRANSGNDR_PRTNRS_12MO_TTL
                        ,shd.SOURCE_SPREAD
                        ,shd.STD_PRTNRS_PRD_TRNSGNDR_TTL
                        ,shd.SURV_CLOSED_DT
                        ,shd.SURV_INVESTIGATOR_ASSGN_DT
                        ,shd.SURV_PATIENT_FOLL_UP
                        ,shd.SURV_PROVIDER_CONTACT
                        ,shd.SURV_PROVIDER_EXAM_REASON
                        ,shd.SYM_NEUROLOGIC_SIGN_SYM
                        ,shd.SYM_OCULAR_MANIFESTATIONS
                        ,shd.SYM_OTIC_MANIFESTATION
                        ,shd.SYM_LATE_CLINICAL_MANIFES
                        ,shd.TRT_TREATMENT_DATE,
                        i.case_uid as case_uid,
                        AM.nbs_case_answer_uid as am_nbs_case_answer_uid,
                        CLN.nbs_case_answer_uid as cln_nbs_case_answer_uid,
                        CMP.nbs_case_answer_uid as cmp_nbs_case_answer_uid,
                        ICC.nbs_case_answer_uid as icc_nbs_case_answer_uid,
                        EPI.nbs_case_answer_uid as epi_nbs_case_answer_uid,
                        HIV.D_INV_HIV_KEY as hiv_key,
                        LF.nbs_case_answer_uid as lf_nbs_case_answer_uid,
                        MH.nbs_case_answer_uid as mh_nbs_case_answer_uid,
                        OBS.nbs_case_answer_uid as obs_nbs_case_answer_uid,
                        PBI.nbs_case_answer_uid as pbi_nbs_case_answer_uid,
                        RI.nbs_case_answer_uid as ri_nbs_case_answer_uid,
                        SH.nbs_case_answer_uid as sh_nbs_case_answer_uid,
                        SYM.nbs_case_answer_uid as sym_nbs_case_answer_uid,
                        TRT.nbs_case_answer_uid as trt_nbs_case_answer_uid,
                        PAT.patient_local_id as pat_patient_local_id,
                        INVEST.PROVIDER_LOCAL_ID as INVESTIGATOR_LOCAL_ID,
                        CRNTI.PROVIDER_LOCAL_ID as CURRENT_INVESTIGATOR_LOCAL_ID,
                        DISP.PROVIDER_LOCAL_ID as DISPOSITIONED_BY_LOCAL_ID,
                        FLD.PROVIDER_LOCAL_ID as INVESTIGATOR_FLD_FOLLOW_UP_LOCAL_ID,
                        INITIV.PROVIDER_LOCAL_ID as INIT_ASGNED_INTERVIEWER_LOCAL_ID,
                        FUP.PROVIDER_LOCAL_ID as  INIT_ASGNED_FLD_FOLLOW_UP_LOCAL_ID,
                        INIT.PROVIDER_LOCAL_ID as INIT_FOLLOW_UP_INVSTGTR_LOCAL_ID,
                        IVW.PROVIDER_LOCAL_ID as INTERVIEWER_ASSIGNED_LOCAL_ID,
                        SUPV.PROVIDER_LOCAL_ID as SUPRVSR_OF_CASE_ASSGNMENT_LOCAL_ID,
                        SUPVFUP.PROVIDER_LOCAL_ID as SUPRVSR_OF_FLD_FOLLOW_UP_LOCAL_ID,
                        SURV.PROVIDER_LOCAL_ID as SURVEILLANCE_INVESTIGATOR_LOCAL_ID,
                        ROW_NUMBER() OVER (ORDER BY i.case_uid ASC) AS RowNum
                        FROM STD_HIV_DATAMART shd
                        INNER JOIN F_STD_PAGE_CASE PC with(nolock) ON  shd.INVESTIGATION_KEY = PC.INVESTIGATION_KEY
                        INNER JOIN INVESTIGATION I with(nolock) ON  shd.INVESTIGATION_KEY = I.INVESTIGATION_KEY
                        INNER JOIN (SELECT DISTINCT INVESTIGATION_KEY, CONFIRMATION_DT
                                      FROM CONFIRMATION_METHOD_GROUP with(nolock)) AS CONF ON CONF.INVESTIGATION_KEY = PC.INVESTIGATION_KEY
                        INNER JOIN D_CASE_MANAGEMENT CM with(nolock) ON CM.INVESTIGATION_KEY = PC.INVESTIGATION_KEY
                        INNER JOIN D_INV_ADMINISTRATIVE AM with(nolock) ON AM.D_INV_ADMINISTRATIVE_KEY = PC.D_INV_ADMINISTRATIVE_KEY
                        INNER JOIN D_INV_CLINICAL CLN with(nolock) ON CLN.D_INV_CLINICAL_KEY = PC.D_INV_CLINICAL_KEY
                        INNER JOIN D_INV_COMPLICATION CMP with(nolock) ON CMP.D_INV_COMPLICATION_KEY = PC.D_INV_COMPLICATION_KEY
                        INNER JOIN D_INV_CONTACT ICC with(nolock) ON ICC.D_INV_CONTACT_KEY = PC.D_INV_CONTACT_KEY
                        INNER JOIN D_INV_EPIDEMIOLOGY EPI with(nolock) ON EPI.D_INV_EPIDEMIOLOGY_KEY = PC.D_INV_EPIDEMIOLOGY_KEY
                        INNER JOIN INV_HIV HIV with(nolock) ON HIV.INVESTIGATION_KEY = PC.INVESTIGATION_KEY
                        INNER JOIN D_INV_LAB_FINDING LF with(nolock) ON LF.D_INV_LAB_FINDING_KEY = PC.D_INV_LAB_FINDING_KEY
                        INNER JOIN D_INV_MEDICAL_HISTORY MH with(nolock) ON MH.D_INV_MEDICAL_HISTORY_KEY = PC.D_INV_MEDICAL_HISTORY_KEY
                        INNER JOIN D_INV_PATIENT_OBS OBS with(nolock) ON OBS.D_INV_PATIENT_OBS_KEY = PC.D_INV_PATIENT_OBS_KEY
                        INNER JOIN D_INV_PREGNANCY_BIRTH PBI with(nolock) ON PBI.D_INV_PREGNANCY_BIRTH_KEY = PC.D_INV_PREGNANCY_BIRTH_KEY
                        INNER JOIN D_INV_RISK_FACTOR RI with(nolock) ON RI.D_INV_RISK_FACTOR_KEY = PC.D_INV_RISK_FACTOR_KEY
                        INNER JOIN D_INV_SOCIAL_HISTORY SH with(nolock) ON SH.D_INV_SOCIAL_HISTORY_KEY = PC.D_INV_SOCIAL_HISTORY_KEY
                        INNER JOIN D_INV_SYMPTOM SYM with(nolock) ON SYM.D_INV_SYMPTOM_KEY = PC.D_INV_SYMPTOM_KEY
                        INNER JOIN D_INV_TREATMENT TRT with(nolock) ON TRT.D_INV_TREATMENT_KEY = PC.D_INV_TREATMENT_KEY
                        INNER JOIN D_PATIENT PAT with(nolock) ON PAT.PATIENT_KEY = PC.PATIENT_KEY
                        INNER JOIN D_PROVIDER INVEST with(nolock) ON INVEST.PROVIDER_KEY = PC.CLOSED_BY_KEY
                        INNER JOIN D_PROVIDER CRNTI with(nolock) ON CRNTI.PROVIDER_KEY = PC.INVESTIGATOR_KEY
                        INNER JOIN D_PROVIDER DISP with(nolock) ON DISP.PROVIDER_KEY = PC.DISPOSITIONED_BY_KEY
                        INNER JOIN D_PROVIDER FLD with(nolock) ON FLD.PROVIDER_KEY = PC.INVSTGTR_FLD_FOLLOW_UP_KEY
                        INNER JOIN D_PROVIDER INITIV with(nolock) ON INITIV.PROVIDER_KEY = PC.INIT_ASGNED_INTERVIEWER_KEY
                        INNER JOIN D_PROVIDER FUP with(nolock) ON FUP.PROVIDER_KEY = PC.INIT_ASGNED_FLD_FOLLOW_UP_KEY
                        INNER JOIN D_PROVIDER INIT with(nolock) ON INIT.PROVIDER_KEY = PC.INIT_FOLLOW_UP_INVSTGTR_KEY
                        INNER JOIN D_PROVIDER IVW with(nolock) ON IVW.PROVIDER_KEY = PC.INTERVIEWER_ASSIGNED_KEY
                        INNER JOIN D_PROVIDER SUPV with(nolock) ON SUPV.PROVIDER_KEY = PC.SUPRVSR_OF_CASE_ASSGNMENT_KEY
                        INNER JOIN D_PROVIDER SUPVFUP with(nolock) ON SUPVFUP.PROVIDER_KEY = PC.SUPRVSR_OF_FLD_FOLLOW_UP_KEY
                        INNER JOIN D_PROVIDER SURV with(nolock) ON SURV.PROVIDER_KEY = PC.SURVEILLANCE_INVESTIGATOR_KEY
                        )
                        SELECT *
                        FROM PaginatedResults
                        WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM STD_HIV_DATAMART;',
           'CASE_UID',
           'RowNum, INVESTIGATION_KEY',
           1
       ),
       (
           'INV_HIV',
           'RDB',
           'RDB_MODERN',
           'with PaginatedResults as (
                        SELECT
                        i.case_uid as case_uid,
                        HIV_STATE_CASE_ID,
                        HIV_LAST_900_TEST_DT,
                        HIV_900_TEST_REFERRAL_DT,
                        HIV_ENROLL_PRTNR_SRVCS_IND,
                        HIV_PREVIOUS_900_TEST_IND,
                        HIV_SELF_REPORTED_RSLT_900,
                        HIV_REFER_FOR_900_TEST,
                        HIV_900_TEST_IND ,
                        HIV_900_RESULT ,
                        HIV_RST_PROVIDED_900_RSLT_IND ,
                        HIV_POST_TEST_900_COUNSELING ,
                        HIV_REFER_FOR_900_CARE_IND ,
                        HIV_KEEP_900_CARE_APPT_IND ,
                        HIV_AV_THERAPY_LAST_12MO_IND ,
                        HIV_AV_THERAPY_EVER_IND,
                        ROW_NUMBER() OVER (ORDER BY i.case_uid ASC) AS RowNum
                        FROM
                        INV_HIV ih
                        inner join INVESTIGATION  i on ih.INVESTIGATION_KEY = i.INVESTIGATION_KEY
                        )
                        SELECT *
                        FROM PaginatedResults
                        WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM INV_HIV;',
           'CASE_UID',
           'RowNum, INVESTIGATION_KEY',
           1
       ),
       (
           'F_STD_PAGE_CASE',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                        select
                               PATIENT.PATIENT_UID
                               ,HOSPITAL.ORGANIZATION_UID as hospital_uid
                               ,HOSPDELIVERY.ORGANIZATION_UID as hospdelivery_uid
                               ,REPORTERORG.ORGANIZATION_UID as reportingorg_uid
                               ,FACILITYORG.ORGANIZATION_UID as facilityorg_uid
                               ,PERSONREPORTER.PROVIDER_UID as personreporter_uid
                               ,PROVDELIVERY.PROVIDER_UID as provdelivery_uid
                               ,MOTHEROBGYN.PROVIDER_UID as motherobgyn_uid
                               ,PEDIATRICIAN.PROVIDER_UID as pediatrician_uid
                               ,PROVIDER.PROVIDER_UID as provider_uid
                               ,PHYSICIAN.PROVIDER_UID as physican_uid
                               ,INVESTIGATION.CASE_UID as case_uid
                               ,CL.PROVIDER_UID as closuer_invest_uid
                               ,DISP.PROVIDER_UID as dispoFup_invest_uid
                               ,FACILITY.ORGANIZATION_UID as facility_uid
                               ,FLD_FUP_INVESTGTR.PROVIDER_UID as fldFup_invest_uid
                               ,PROVIDER_FLD_FUP.PROVIDER_UID as provider_fup_uid
                               ,SUPRVSR_FLD_FUP.PROVIDER_UID as suprvsr_fup_uid
                               ,INIT_FLD_FUP.PROVIDER_UID as int_fup_uid
                               , INIT_INVSTGR_PHC.PROVIDER_UID as  int_invst_uid
                               ,INIT_INTERVIEWER.PROVIDER_UID as interviewer_uid
                               ,SURV.PROVIDER_UID as surv_invst_uid
                               ,CA.PROVIDER_UID as suprvsr_uid
                               , ROW_NUMBER() OVER (ORDER BY INVESTIGATION.case_uid ASC) AS RowNum
                               from F_STD_PAGE_CASE fsshc
                               JOIN dbo.D_PATIENT PATIENT	with(nolock)  on PATIENT.PATIENT_KEY = fsshc.PATIENT_KEY
                               JOIN dbo.D_ORGANIZATION  HOSPITAL with(nolock) ON fsshc.HOSPITAL_KEY= HOSPITAL.ORGANIZATION_KEY
                               JOIN dbo.D_ORGANIZATION  HOSPDELIVERY with(nolock) ON fsshc.DELIVERING_HOSP_KEY= HOSPDELIVERY.ORGANIZATION_KEY
                               JOIN dbo.D_ORGANIZATION REPORTERORG with(nolock) ON fsshc.ORG_AS_REPORTER_KEY= REPORTERORG.ORGANIZATION_KEY
                               JOIN dbo.D_ORGANIZATION FACILITYORG with(nolock) ON fsshc.ORDERING_FACILITY_KEY= FACILITYORG.ORGANIZATION_KEY
                               JOIN dbo.D_PROVIDER PERSONREPORTER with(nolock) ON  fsshc.PERSON_AS_REPORTER_KEY= PERSONREPORTER.PROVIDER_KEY
                               JOIN dbo.D_PROVIDER PROVDELIVERY with(nolock) ON fsshc.DELIVERING_MD_KEY= PROVDELIVERY.PROVIDER_KEY
                               JOIN dbo.D_PROVIDER MOTHEROBGYN with(nolock) ON fsshc.MOTHER_OB_GYN_KEY= MOTHEROBGYN.PROVIDER_KEY
                               JOIN dbo.D_PROVIDER PEDIATRICIAN with(nolock) ON fsshc.PEDIATRICIAN_KEY= PEDIATRICIAN.PROVIDER_KEY
                               JOIN dbo.D_PROVIDER PROVIDER with(nolock) ON fsshc.INVESTIGATOR_KEY= PROVIDER.PROVIDER_KEY
                               JOIN dbo.D_PROVIDER PHYSICIAN with(nolock) ON fsshc.PHYSICIAN_KEY= PHYSICIAN.PROVIDER_KEY
                               JOIN dbo.INVESTIGATION  INVESTIGATION with(nolock) ON fsshc.INVESTIGATION_KEY= INVESTIGATION.INVESTIGATION_KEY
                               JOIN dbo.D_PROVIDER CL with(nolock) ON fsshc.CLOSED_BY_KEY= CL.PROVIDER_KEY
                               JOIN dbo.D_PROVIDER DISP with(nolock) ON fsshc.DISPOSITIONED_BY_KEY= DISP.PROVIDER_KEY
                               JOIN dbo.D_ORGANIZATION  FACILITY with(nolock) ON fsshc.FACILITY_FLD_FOLLOW_UP_KEY= FACILITY.ORGANIZATION_KEY
                               JOIN dbo.D_PROVIDER FLD_FUP_INVESTGTR with(nolock) ON fsshc.INVSTGTR_FLD_FOLLOW_UP_KEY = FLD_FUP_INVESTGTR.PROVIDER_KEY
                               JOIN dbo.D_PROVIDER PROVIDER_FLD_FUP with(nolock) ON fsshc.PROVIDER_FLD_FOLLOW_UP_KEY = PROVIDER_FLD_FUP.PROVIDER_KEY
                               JOIN dbo.D_PROVIDER SUPRVSR_FLD_FUP with(nolock) ON fsshc.SUPRVSR_OF_FLD_FOLLOW_UP_KEY = SUPRVSR_FLD_FUP.PROVIDER_KEY
                               JOIN dbo.D_PROVIDER INIT_FLD_FUP with(nolock) ON fsshc.INIT_ASGNED_FLD_FOLLOW_UP_KEY= INIT_FLD_FUP.PROVIDER_KEY
                               JOIN dbo.D_PROVIDER INIT_INVSTGR_PHC with(nolock) ON fsshc.INIT_FOLLOW_UP_INVSTGTR_KEY= INIT_INVSTGR_PHC.PROVIDER_KEY
                               JOIN dbo.D_PROVIDER INIT_INTERVIEWER with(nolock) ON fsshc.INIT_ASGNED_INTERVIEWER_KEY= INIT_INTERVIEWER.PROVIDER_KEY
                               JOIN dbo.D_PROVIDER INTERVIEWER with(nolock) ON fsshc.INTERVIEWER_ASSIGNED_KEY= INTERVIEWER.PROVIDER_KEY
                               JOIN dbo.D_PROVIDER SURV with(nolock) ON fsshc.SURVEILLANCE_INVESTIGATOR_KEY= SURV.PROVIDER_KEY
                               JOIN dbo.D_PROVIDER CA with(nolock) ON fsshc.SUPRVSR_OF_CASE_ASSGNMENT_KEY= CA.PROVIDER_KEY
                        )
                        SELECT *
                        FROM PaginatedResults
                        WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM F_STD_PAGE_CASE;',
           'CASE_UID',
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
           'with PaginatedResults as (
                        SELECT
                        i.case_uid
                        ,lg.BUSINESS_OBJECT_UID
                        ,dpat.PATIENT_UID
                        ,dpro1.provider_uid as investigator_id
                        ,dpro2.provider_uid as physician_id
                        ,dpro3.provider_uid as person_as_reporter_uid
                        ,dorg1.organization_uid as organization_id
                        ,dorg2.organization_uid as hospital_uid
                        ,ih.ILLNESS_DURATION
                        ,ih.ILLNESS_DURATION_UNIT
                        ,ih.PATIENT_AGE_AT_ONSET
                        ,ih.PATIENT_AGE_AT_ONSET_UNIT
                        ,ih.FOOD_HANDLR_IND
                        ,ih.DAYCARE_ASSOCIATION_IND
                        ,ih.DETECTION_METHOD
                        ,ih.DETECTION_METHOD_OTHER
                        ,ih.PATIENT_PREGNANCY_STATUS
                        ,ih.PELVIC_INFLAMMATORY_DISS_IND
                        ,con.CONDITION_CD
                        ,ih.Inv_Assigned_dt_key
                        ,ROW_NUMBER() OVER (ORDER BY i.case_uid ASC) AS RowNum
                        FROM
                        GENERIC_CASE ih
                        inner join INVESTIGATION  i on ih.INVESTIGATION_KEY = i.INVESTIGATION_KEY
                        INNER JOIN CONDITION con WITH (NOLOCK)
                        ON con.CONDITION_KEY = ih.CONDITION_KEY
                        LEFT OUTER JOIN LDF_GROUP lg WITH (NOLOCK)
                        ON lg.LDF_GROUP_KEY = ih.LDF_GROUP_KEY
                        LEFT OUTER JOIN D_PATIENT dpat WITH (NOLOCK)
                        ON ih.PATIENT_KEY = dpat.PATIENT_KEY
                        LEFT OUTER JOIN D_PROVIDER dpro1 WITH (NOLOCK)
                        ON ih.Investigator_key = dpro1.PROVIDER_KEY
                        LEFT OUTER JOIN D_PROVIDER dpro2 WITH (NOLOCK)
                        ON ih.Physician_key = dpro2.PROVIDER_KEY
                        LEFT OUTER JOIN D_PROVIDER dpro3 WITH (NOLOCK)
                        ON ih.Reporter_key = dpro3.PROVIDER_KEY
                        LEFT OUTER JOIN D_ORGANIZATION dorg1 WITH (NOLOCK)
                        ON ih.Rpt_Src_Org_key = dorg1.Organization_key
                        LEFT OUTER JOIN D_ORGANIZATION dorg2 WITH (NOLOCK)
                        ON ih.ADT_HSPTL_KEY = dorg2.Organization_key
                        )
                        SELECT *
                        FROM PaginatedResults
                        WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM GENERIC_CASE;',
           'CASE_UID',
           'RowNum, INVESTIGATION_KEY',
           1
       ),
       (
           'CRS_CASE',
           'RDB',
           'RDB_MODERN',
           'with PaginatedResults as (
                        SELECT
                        i.case_uid as case_uid
                        ,lg.BUSINESS_OBJECT_UID as BUSINESS_OBJECT_UID
                        ,dpat.PATIENT_UID as patient_uid
                        ,dpro1.provider_uid as investigator_id
                        ,dpro2.provider_uid as physician_id
                        ,dpro3.provider_uid as person_as_reporter_uid
                        ,dorg1.organization_uid as organization_id
                        ,dorg2.organization_uid as hospital_uid
                        ,con.CONDITION_CD
                        ,ih.Inv_Assigned_dt_key
                        ,ih.AT_PREGNANCY_18YOUNGR_CHILDNBR
                        ,ih.AUTOPSY_PERFORMED_IND
                        ,ih.BIRTH_DELIVERED_IN_US_NBR
                        ,ih.BIRTH_STATE
                        ,ih.BIRTH_WEIGHT
                        ,ih.BIRTH_WEIGHT_UNIT
                        ,ih.BY_WHOM_NOT_MD_DIAGNSD_RUBELLA
                        ,ih.CHILD_18YOUNGR_RUBELLA_VACCD
                        ,ih.CHILD_AGE_AT_DIAGNOSIS_UNIT
                        ,ih.CHILD_AGE_AT_THIS_DIAGNOSIS
                        ,ih.CHILD_CONGNITAL_HEART_DISEASE
                        ,ih.CHILD_DERMAL_ERYTHROPOISESIS
                        ,ih.CHILD_CONGNITAL_GLAUCOMA
                        ,ih.CHILD_JAUNDICE
                        ,ih.CHILD_LOW_PLATELETS
                        ,ih.CHILD_MENINGOENCEPHALITIS
                        ,ih.CHILD_MICROENCEPHALY
                        ,ih.CHILD_OTHER_ABNORMALITIES
                        ,ih.CHILD_PURPURA
                        ,ih.CHILD_RADIOLUCENT_BONE
                        ,ih.CHILD_CATARACTS
                        ,ih.CHILD_ENLARGED_LIVER
                        ,ih.CHILD_ENLARGED_SPLEEN
                        ,ih.CHILD_HEARING_LOSS
                        ,ih.CHILD_MENTAL_RETARDATION
                        ,ih.CHILD_OTHER_ABNORMALITIES_1
                        ,ih.CHILD_OTHER_ABNORMALITIES_2
                        ,ih.CHILD_OTHER_ABNORMALITIES_3
                        ,ih.CHILD_OTHER_ABNORMALITIES_4
                        ,ih.CHILD_PATENT_DUCTUS_ARTERIOSUS
                        ,ih.CHILD_PIGMENTARY_RETINOPATHY
                        ,ih.CHILD_PULMONIC_STENOSIS
                        ,ih.CHILD_RUBELLA_LAB_TEST_DONE
                        ,ih.REASON_NOT_A_CRS_CASE
                        ,ih.DEATH_CERTIFICATE_2NDARY_CAUSE
                        ,ih.DEATH_CERTIFICATE_PRIMARY_CAUS
                        ,ih.DIFFERENCE_BETWEEN_TEST_1_2
                        ,ih.FAMILYPLAND_PRIOR_CONCEPTION
                        ,ih.FINAL_ANATOMICAL_DEATH_CAUSE
                        ,ih.PRENATAL_FIRST_VISIT_DT
                        ,ih.GESTATIONAL_AGE_IN_WK_AT_BIRTH
                        ,ih.HEALTH_PROVIDER_LAST_EVAL_DT
                        ,ih.IGM_EIA_1_METHOD_USED
                        ,ih.IGM_EIA_2_METHOD_USED
                        ,ih.IGM_EIA_NONCAPTURE_RESULT
                        ,ih.IGM_EIA_OTHER_TST_RESULT_VAL
                        ,ih.IGM_EIA_TEST_1_RESULT_VAL
                        ,ih.IGM_EIA_TEST_2_RESULT_VAL
                        ,ih.INFANT_DEATH_FRM_CRS
                        ,ih.MATERNAL_ILL_CLINICAL_FEATURE
                        ,ih.MOTHER_AGE_AT_GIVEN_BIRTH
                        ,ih.MOTHER_ARTHRALGIA_ARTHRITIS
                        ,ih.MOTHER_BIRTH_CNTRY
                        ,ih.MOTHER_EXPOSD_TO_RUBELLA_CASE
                        ,ih.MOTHER_GIVEN_PRIOR_BIRTH_IN_US
                        ,ih.MOTHER_HAD_FEVER
                        ,ih.MOTHER_HAD_LYMPHADENOPATHY
                        ,ih.MOTHER_HAS_MACULOPAPULAR_RASH
                        ,ih.MOTHER_IMMUNIZED_IND
                        ,ih.MOTHER_KNOW_EXPOSED_AT_WHERE
                        ,ih.MOTHER_LIVING_IN_US_YRS
                        ,ih.MOTHER_OCCUPATION_ATCONCEPTION
                        ,ih.MOTHER_OTHER_VACC_INFO_SRC
                        ,ih.MOTHER_RASH_ONSET_DT
                        ,ih.MOTHER_RELATIONTO_RUBELLA_CASE
                        ,ih.MOTHER_RUBELLA_CASE_EXPOSE_DT
                        ,ih.MOTHER_TRAVEL_BACK_US_1_DT
                        ,ih.MOTHER_TRAVEL_BACK_US_2_DT
                        ,ih.MOTHER_TRAVEL_OUT_US_1_DT
                        ,ih.MOTHER_TRAVEL_OUT_US_2_DT
                        ,ih.MOTHER_TRAVEL_1_TO_CNTRY
                        ,ih.MOTHER_TRAVEL_2_TO_CNTRY
                        ,ih.MOTHER_UNK_EXPOSURE_TRAVEL_IND
                        ,ih.MOTHER_IS_A_RPTD_RUBELLA_CASE
                        ,ih.MOTHERRUBELLA_IMMUNIZE_INFOSRC
                        ,ih.OTHER_CONGNITAL_HEART_DISS_IND
                        ,ih.OTHER_CONGNITALHEART_DISS_DESC
                        ,ih.OTHER_RELATIONSHIP
                        ,ih.OTHER_RUBELLA_LAB_TEST_DESC
                        ,ih.OTHER_RUBELLA_LAB_TEST_DONE
                        ,ih.OTHER_RUBELLA_LAB_TEST_DT
                        ,ih.OTHER_RUBELLA_LAB_TEST_RESULT
                        ,ih.OTHER_RUBELLA_SPECIMEN_TYPE
                        ,ih.OTHER_RUBELLA_TEST_RESULT_VAL
                        ,ih.PREGNANCY_MO_RUBELLA_SYMPTM_UP
                        ,ih.PRENATAL_CARE_THIS_PREGNANCY
                        ,ih.PREVIOUS_PREGNANCY_NBR
                        ,ih.RT_PCR_DT
                        ,ih.RT_PCR_OTHER_SPECIMEN_SRC
                        ,ih.RT_PCR_PERFORMED
                        ,ih.RT_PCR_RESULT
                        ,ih.RT_PCR_SRC
                        ,ih.RT_PCR_TEST_RESULT_VAL
                        ,ih.RUBELLA_IGG_TEST_1
                        ,ih.RUBELLA_IGG_TEST_1_DT
                        ,ih.RUBELLA_IGG_TEST_1_RESULT
                        ,ih.RUBELLA_IGG_TEST_2
                        ,ih.RUBELLA_IGG_TEST_2_DT
                        ,ih.RUBELLA_IGG_TEST_2_RESULT
                        ,ih.RUBELLA_IGG_TEST1_RESULT_VAL
                        ,ih.RUBELLA_IGG_TEST2_RESULT_VAL
                        ,ih.RUBELLA_IGM_EIA_CAPTURE
                        ,ih.RUBELLA_IGM_EIA_CAPTURE_DT
                        ,ih.RUBELLA_IGM_EIA_CAPTURE_RESULT
                        ,ih.RUBELLA_IGM_EIA_NONCAPTURE_DT
                        ,ih.RUBELLA_IGM_EIA_TESTED
                        ,ih.RUBELLA_IGM_OTHER_TEST
                        ,ih.RUBELLA_IGM_OTHER_TEST_DESC
                        ,ih.RUBELLA_IGM_OTHER_TEST_DT
                        ,ih.RUBELLA_IGM_OTHER_TEST_RESULT
                        ,ih.RUBELLA_LIKE_ILL_IN_PREGNANCY
                        ,ih.RUBELLA_SPECIMEN_TYPE
                        ,ih.RUBELLAVACCD_18YOUNGR_CHILDNBR
                        ,ih.SEROLOGICAL_CONFIRMD_AT_ILL
                        ,ih.SEROLOGICAL_TST_BEFR_PREGNANCY
                        ,ih.SEROLOGICALLY_CONFIRMD_DT
                        ,ih.SEROLOGICALLY_CONFIRMD_RESULT
                        ,ih.SPECIMEN_TO_CDC_FOR_GENOTYPING
                        ,ih.TOTAL_LIVE_BIRTH_NBR
                        ,ih.VACCINE_SRC
                        ,ih.VIRUS_ISOLATION_DT
                        ,ih.VIRUS_ISOLATION_OTHER_SRC
                        ,ih.VIRUS_ISOLATION_PERFORMED
                        ,ih.VIRUS_ISOLATION_RESULT
                        ,ih.VIRUS_ISOLATION_SPECIMEN_SRC
                        ,ih.YR_MOTHER_PRIOR_DELIVERY_IN_US
                        ,ih.PRENATAL_CARE_OBTAINED_FRM_2
                        ,ih.PRENATAL_CARE_OBTAINED_FRM_3
                        ,ih.PRENATAL_CARE_OBTAINED_FRM_1
                        ,ih.MOTHER_RUBELLA_ACQUIRED_PLACE
                        ,ih.MOTHER_RUBELLA_ACQUIRED_CNTRY
                        ,ih.MOTHER_RUBELLA_ACQUIRED_CITY
                        ,ih.MOTHER_RUBELLA_ACQUIRED_STATE
                        ,ih.MOTHER_RUBELLA_ACQUIRED_CNTY
                        ,ih.SENT_FOR_GENOTYPING_DT
                        ,ih.DIAGNOSED_BY_PHYSICIAN_IND
                        ,ih.MOTHER_RUBELLA_LAB_TEST_IND
                        ,ih.MOTHER_VACCINATED_DT
                        ,ih.GENOTYPE_SEQUENCED_CRS
                        ,ih.GENOTYPE_ID_CRS
                        ,ih.GENOTYPE_OTHER_ID_CRS
                        ,ROW_NUMBER() OVER (ORDER BY i.case_uid ASC) AS RowNum
                        FROM
                        CRS_CASE ih
                        inner join INVESTIGATION  i on ih.INVESTIGATION_KEY = i.INVESTIGATION_KEY
                        INNER JOIN CONDITION con WITH (NOLOCK)
                        ON con.CONDITION_KEY = ih.CONDITION_KEY
                        LEFT OUTER JOIN LDF_GROUP lg WITH (NOLOCK)
                        ON lg.LDF_GROUP_KEY = ih.LDF_GROUP_KEY
                        LEFT OUTER JOIN D_PATIENT dpat WITH (NOLOCK)
                        ON ih.PATIENT_KEY = dpat.PATIENT_KEY
                        LEFT OUTER JOIN D_PROVIDER dpro1 WITH (NOLOCK)
                        ON ih.Investigator_key = dpro1.PROVIDER_KEY
                        LEFT OUTER JOIN D_PROVIDER dpro2 WITH (NOLOCK)
                        ON ih.Physician_key = dpro2.PROVIDER_KEY
                        LEFT OUTER JOIN D_PROVIDER dpro3 WITH (NOLOCK)
                        ON ih.Reporter_key = dpro3.PROVIDER_KEY
                        LEFT OUTER JOIN D_ORGANIZATION dorg1 WITH (NOLOCK)
                        ON ih.Rpt_Src_Org_key = dorg1.Organization_key
                        LEFT OUTER JOIN D_ORGANIZATION dorg2 WITH (NOLOCK)
                        ON ih.ADT_HSPTL_KEY = dorg2.Organization_key
                        )
                        SELECT *
                        FROM PaginatedResults
                        WHERE RowNum BETWEEN :startRow AND :endRow;',
           'CASE_UID',
           'WHAT WILL GO HERE',
           'RowNum, INVESTIGATION_KEY',
            1
       ),
       (
           'BMIRD_CASE',
           'RDB',
           'RDB_MODERN',
           'with PaginatedResults as (
                        select
                        i.case_uid as case_uid
                        ,lg.BUSINESS_OBJECT_UID as BUSINESS_OBJECT_UID
                        ,dpat.PATIENT_UID as PATIENT_UID
                        ,dpro1.provider_uid as investigator_id
                        ,dpro2.provider_uid as physician_id
                        ,dpro3.provider_uid as person_as_reporter_uid
                        ,dorg1.organization_uid as organization_id
                        ,dorg2.organization_uid as hospital_uid
                        ,dorg3.organization_uid as chronic_care_fac_uid
                        ,dorg4.organization_uid as daycare_fac_uid
                        ,con.CONDITION_CD
                        ,atm.ANTIMICROBIAL_AGENT_TESTED_IND
                        ,atm.SUSCEPTABILITY_METHOD
                        ,atm.S_I_R_U_RESULT
                        ,atm.MIC_SIGN
                        ,atm.MIC_VALUE
                        ,ih.Inv_Assigned_dt_key
                        ,ih.TREATMENT_HOSPITAL_KEY
                        ,ih.TRANSFERED_IND
                        ,ih.BIRTH_WEIGHT_IN_GRAMS
                        ,ih.BIRTH_WEIGHT_POUNDS
                        ,ih.WEIGHT_IN_POUNDS
                        ,ih.WEIGHT_IN_OUNCES
                        ,ih.WEIGHT_IN_KILOGRAM
                        ,ih.WEIGHT_UNKNOWN
                        ,ih.HEIGHT_IN_FEET
                        ,ih.HEIGHT_IN_INCHES
                        ,ih.HEIGHT_IN_CENTIMETERS
                        ,ih.HEIGHT_UNKNOWN
                        ,ih.OTH_STREP_PNEUMO1_CULT_SITES
                        ,ih.OTH_STREP_PNEUMO2_CULT_SITES
                        ,ih.IHC_SPECIMEN_1
                        ,ih.IHC_SPECIMEN_2
                        ,ih.IHC_SPECIMEN_3
                        ,ih.SAMPLE_COLLECTION_DT
                        ,ih.CONJ_MENING_VACC
                        ,ih.TREATMENT_HOSPITAL_NM
                        ,ih.OTH_TYPE_OF_INSURANCE
                        ,ih.BIRTH_WEIGHT_OUNCES
                        ,ih.PREGNANT_IND
                        ,ih.OUTCOME_OF_FETUS
                        ,ih.UNDER_1_MONTH_IND
                        ,ih.GESTATIONAL_AGE
                        ,ih.BACTERIAL_SPECIES_ISOLATED
                        ,ih.FIRST_POSITIVE_CULTURE_DT
                        ,ih.UNDERLYING_CONDITION_IND
                        ,ih.PATIENT_YR_IN_COLLEGE
                        ,ih.CULTURE_SEROTYPE
                        ,ih.PATIENT_STATUS_IN_COLLEGE
                        ,ih.PATIENT_CURR_LIVING_SITUATION
                        ,ih.HIB_VACC_RECEIVED_IND
                        ,ih.CULTURE_SEROGROUP
                        ,ih.ATTENDING_COLLEGE_IND
                        ,ih.OXACILLIN_ZONE_SIZE
                        ,ih.OXACILLIN_INTERPRETATION
                        ,ih.PNEUVACC_RECEIVED_IND
                        ,ih.PNEUCONJ_RECEIVED_IND
                        ,ih.FIRST_ADDITIONAL_SPECIMEN_DT
                        ,ih.SECOND_ADDITIONAL_SPECIMEN_DT
                        ,ih.PATIENT_HAD_SURGERY_IND
                        ,ih.SURGERY_DT
                        ,ih.PATIENT_HAVE_BABY_IND
                        ,ih.BABY_DELIVERY_DT
                        ,ih.IDENT_THRU_AUDIT_IND
                        ,ih.SAME_PATHOGEN_RECURRENT_IND
                        ,ih.OTHER_SPECIES_ISOLATE_SITE
                        ,ih.OTHER_CASE_IDENT_METHOD
                        ,ih.OTHER_HOUSING_OPTION
                        ,ih.PATIENT_CURR_ATTEND_SCHOOL_NM
                        ,ih.POLYSAC_MENINGOC_VACC_IND
                        ,ih.FAMILY_MEDICAL_INSURANCE_TYPE
                        ,ih.HIB_CONTACT_IN_LAST_2_MON_IND
                        ,ih.TYPE_HIB_CONTACT_IN_LAST_2_MON
                        ,ih.PRETERM_BIRTH_WK_NBR
                        ,ih.IMMUNOSUPRESSION_HIV_STATUS
                        ,ih.ACUTE_SERUM_AVAILABLE_IND
                        ,ih.ACUTE_SERUM_AVAILABLE_DT
                        ,ih.CONVALESNT_SERUM_AVAILABLE_IND
                        ,ih.CONVALESNT_SERUM_AVAILABLE_DT
                        ,ih.BIRTH_OUTSIDE_HSPTL_IND
                        ,ih.BIRTH_OUTSIDE_HSPTL_LOCATION
                        ,ih.BABY_HSPTL_DISCHARGE_DTTIME
                        ,ih.BABY_SAME_HSPTL_READMIT_IND
                        ,ih.BABY_SAME_HSPTL_READMIT_DTTIME
                        ,ih.FRM_HOME_TO_DIF_HSPTL_IND
                        ,ih.FRM_HOME_TO_DIF_HSPTL_DTTIME
                        ,ih.MOTHER_LAST_NM
                        ,ih.MOTHER_FIRST_NM
                        ,ih.MOTHER_HOSPTL_ADMISSION_DTTIME
                        ,ih.MOTHER_PATIENT_CHART_NBR
                        ,ih.MOTHER_PENICILLIN_ALLERGY_IND
                        ,ih.MEMBRANE_RUPTURE_DTTIME
                        ,ih.MEMBRANE_RUPTURE_GE_18HRS_IND
                        ,ih.RUPTURE_BEFORE_LABOR_ONSET
                        ,ih.MEMBRANE_RUPTURE_TYPE
                        ,ih.DELIVERY_TYPE
                        ,ih.MOTHER_INTRAPARTUM_FEVER_IND
                        ,ih.FIRST_INTRAPARTUM_FEVER_DTTIME
                        ,ih.RECEIVED_PRENATAL_CARE_IND
                        ,ih.PRENATAL_CARE_IN_LABOR_CHART
                        ,ih.PRENATAL_CARE_VISIT_NBR
                        ,ih.FIRST_PRENATAL_CARE_VISIT_DT
                        ,ih.LAST_PRENATAL_CARE_VISIT_DT
                        ,ih.LAST_PRENATAL_CARE_VISIT_EGA
                        ,ih.GBS_BACTERIURIA_IN_PREGNANCY
                        ,ih.PREVIOUS_BIRTH_WITH_GBS_IND
                        ,ih.GBS_CULTURED_BEFORE_ADMISSION
                        ,ih.GBS_1ST_CULTURE_DT
                        ,ih.GBS_1ST_CULTURE_POSITIVE_IND
                        ,ih.GBS_2ND_CULTURE_DT
                        ,ih.GBS_2ND_CULTURE_POSITIVE_IND
                        ,ih.GBS_AFTER_ADM_BEFORE_DELIVERY
                        ,ih.AFTER_ADM_GBS_CULTURE_DT
                        ,ih.GBS_CULTURE_DELIVERY_AVAILABLE
                        ,ih.INTRAPARTUM_ANTIBIOTICS_GIVEN
                        ,ih.FIRST_ANTIBIOTICS_GIVEN_DTTIME
                        ,ih.INTRAPARTUMANTIBIOTICSINTERVAL
                        ,ih.INTRAPARTUM_ANTIBIOTICS_REASON
                        ,ih.BABY_BIRTH_TIME
                        ,ih.NEISERRIA_2NDARY_CASE_IND
                        ,ih.NEISERRIA_2ND_CASE_CONTRACT
                        ,ih.OTHER_2NDARY_CASE_TYPE
                        ,ih.NEISERRIA_RESIST_TO_RIFAMPIN
                        ,ih.NEISERRIA_RESIST_TO_SULFA
                        ,ih.FIRST_HSPTL_DISCHARGE_TIME
                        ,ih.FIRST_HSPTL_READMISSION_TIME
                        ,ih.SECOND_HSPTL_ADMISSION_TIME
                        ,ih.ABCCASE
                        ,ih.HSPTL_MATERNAL_ADMISSION_TIME
                        ,ih.MEMBRANE_RUPTURE_TIME
                        ,ih.INTRAPARTUM_FEVER_RECORD_TIME
                        ,ih.ANTIBIOTICS_1ST_ADMIN_TIME
                        ,ih.BMIRD_MULTI_VAL_GRP_KEY
                        ,ih.OTHER_PRIOR_ILLNESS
                        ,ih.OTHER_MALIGNANCY
                        ,ih.ORGAN_TRANSPLANT
                        ,ih.DAYCARE_IND
                        ,ih.NURSING_HOME_IND
                        ,ih.TYPES_OF_OTHER_INFECTION
                        ,ih.BACTERIAL_OTHER_SPECIED
                        ,ih.STERILE_SITE_OTHER
                        ,ih.UNDERLYING_CONDITIONS_OTHER
                        ,ih.CULTURE_SEROGROUP_OTHER
                        ,ih.PERSISTENT_DISEASE_IND
                        ,ih.GBS_CULTURE_POSITIVE_IND
                        ,ih.BACTERIAL_OTHER_ISOLATED
                        ,ih.FAMILY_MED_INSURANCE_TYPE_OTHE
                        ,ih.PRIOR_STATE_CASE_ID
                        ,ih.BIRTH_CNTRY_CD
                        ,ih.INITIAL_HSPTL_NAME
                        ,ih.BIRTH_HSPTL_NAME
                        ,ih.FROM_HOME_HSPTL_NAME
                        ,ih.CULTURE_IDENT_ORG_NAME
                        ,ih.TRANSFER_FRM_HSPTL_NAME
                        ,ih.CASE_REPORT_STATUS
                        ,ih.TRANSFER_FRM_HSPTL_ID
                        ,ih.BIRTH_HSPTL_ID
                        ,ih.DIF_HSPTL_ID
                        ,ih.ABC_STATE_CASE_ID
                        ,ih.INV_PATIENT_CHART_NBR
                        ,ih.OTHSPEC1
                        ,ih.OTHSPEC2
                        ,ih.INTBODYSITE
                        ,ih.OTHILL2
                        ,ih.OTHILL3
                        ,ih.OTHNONSTER
                        ,ih.OTHSEROTYPE
                        ,ih.HINFAGE
                        ,ih.ABCSINVLN
                        ,ih.ABCSINVFN
                        ,ih.ABCSINVEMAIL
                        ,ih.ABCSINVTELE
                        ,ih.ABCSINVEXT
                        ,ROW_NUMBER() OVER (ORDER BY i.case_uid ASC) AS RowNum
                        FROM
                        BMIRD_CASE ih
                        inner join INVESTIGATION  i on ih.INVESTIGATION_KEY = i.INVESTIGATION_KEY
                        INNER JOIN CONDITION con WITH (NOLOCK)
                        ON con.CONDITION_KEY = ih.CONDITION_KEY
                        LEFT OUTER JOIN LDF_GROUP lg WITH (NOLOCK)
                        ON lg.LDF_GROUP_KEY = ih.LDF_GROUP_KEY
                        LEFT OUTER JOIN D_PATIENT dpat WITH (NOLOCK)
                        ON ih.PATIENT_KEY = dpat.PATIENT_KEY
                        LEFT OUTER JOIN D_PROVIDER dpro1 WITH (NOLOCK)
                        ON ih.Investigator_key = dpro1.PROVIDER_KEY
                        LEFT OUTER JOIN D_PROVIDER dpro2 WITH (NOLOCK)
                        ON ih.Physician_key = dpro2.PROVIDER_KEY
                        LEFT OUTER JOIN D_PROVIDER dpro3 WITH (NOLOCK)
                        ON ih.Reporter_key = dpro3.PROVIDER_KEY
                        LEFT OUTER JOIN D_ORGANIZATION dorg1 WITH (NOLOCK)
                        ON ih.Rpt_Src_Org_key = dorg1.Organization_key
                        LEFT OUTER JOIN D_ORGANIZATION dorg2 WITH (NOLOCK)
                        ON ih.ADT_HSPTL_KEY = dorg2.Organization_key
                        LEFT OUTER JOIN D_ORGANIZATION dorg3 WITH (NOLOCK)
                        ON ih.NURSING_HOME_KEY = dorg3.Organization_key
                        LEFT OUTER JOIN D_ORGANIZATION dorg4 WITH (NOLOCK)
                        ON ih.DAYCARE_FACILITY_KEY = dorg4.Organization_key
                        LEFT OUTER JOIN ANTIMICROBIAL atm WITH (NOLOCK)
                        ON atm.ANTIMICROBIAL_GRP_KEY = ih.ANTIMICROBIAL_GRP_KEY
                        )
                        SELECT *
                        FROM PaginatedResults
                        WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM BMIRD_CASE;',
           'CASE_UID',
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
                                     SELECT DISTINCT INVESTIGATION_LOCAL_ID+''_''+CONVERT(VARCHAR(24), PHC_ADD_TIME, 121) AS COMPOSITE_KEY, CASE_LAB_DATAMART.*,
                                            ROW_NUMBER() OVER (ORDER BY CASE_LAB_DATAMART.INVESTIGATION_LOCAL_ID ASC, CASE_LAB_DATAMART.PHC_ADD_TIME ASC) AS RowNum
                                     FROM CASE_LAB_DATAMART
                                  )
                                  SELECT *
                                  FROM PaginatedResults
                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM CASE_LAB_DATAMART;',
           'COMPOSITE_KEY',
           'RowNum, COMPOSITE_KEY, INVESTIGATION_KEY',
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
                        select dc.LOCAL_ID as local_id
                        ,org.ORGANIZATION_UID as organization_uid
                        ,pv1.PROVIDER_UID as investigator_uid
                        ,pv2.PROVIDER_UID  as dispositioned_by_uid
                        ,pt1.PATIENT_UID as third_party_entity_uid
                        ,pt2.PATIENT_UID  as pat_contact_uid --key
                        ,pt3.PATIENT_UID  as subject_uid
                        ,inv1.CASE_UID as third_party_case_uid
                        ,inv2.CASE_UID as subject_case_uid
                        ,inv3.CASE_UID as contact_case_uid
                        ,ROW_NUMBER() OVER (ORDER BY nc.CONTACT_KEY ASC) AS RowNum
                        from F_CONTACT_RECORD_CASE nc
                        INNER JOIN
                               D_CONTACT_RECORD dc with (nolock) on dc.D_CONTACT_RECORD_KEY = nc.D_CONTACT_RECORD_KEY
                        INNER JOIN
                               D_ORGANIZATION org  with (nolock) on org.ORGANIZATION_KEY  = nc.CONTACT_EXPOSURE_SITE_KEY
                        INNER JOIN
                               D_PROVIDER pv1  with (nolock) on pv1.PROVIDER_KEY  = nc.CONTACT_INVESTIGATOR_KEY
                        INNER JOIN
                               D_PROVIDER pv2  with (nolock) on pv2.PROVIDER_KEY  = nc.DISPOSITIONED_BY_KEY
                        INNER JOIN
                               D_PATIENT pt1  with (nolock) on pt1.PATIENT_KEY = nc.THIRD_PARTY_ENTITY_KEY
                        INNER JOIN
                               D_PATIENT pt2  with (nolock) on pt2.PATIENT_KEY = nc.CONTACT_KEY
                        INNER JOIN
                               D_PATIENT pt3  with (nolock) on pt3.PATIENT_KEY = nc.SUBJECT_KEY
                        INNER JOIN
                               INVESTIGATION inv1  with (nolock) on inv1.INVESTIGATION_KEY = nc.THIRD_PARTY_INVESTIGATION_KEY
                        INNER JOIN
                               INVESTIGATION inv2  with (nolock) on inv2.INVESTIGATION_KEY = nc.SUBJECT_INVESTIGATION_KEY
                        INNER JOIN
                               INVESTIGATION inv3  with (nolock) on inv3.INVESTIGATION_KEY = nc.CONTACT_INVESTIGATION_KEY
                        )
                        SELECT *
                        FROM PaginatedResults
                        WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM F_CONTACT_RECORD_CASE;',
           'pat_contact_uid',
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
           'TB_PAM_UID',
           'RowNum, TB_PAM_UID, D_TB_HIV_KEY',
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
           'TB_PAM_UID',
           'RowNum, TB_PAM_UID, D_TB_PAM_KEY',
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
           'VAR_PAM_UID',
           'RowNum, VAR_PAM_UID, D_VAR_PAM_KEY',
           1
       ),
       (
           'D_ADDL_RISK',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                                     SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,ISNULL(SEQ_NBR,1)) AS COMPOSITE_KEY, D_ADDL_RISK.*,
                                            ROW_NUMBER() OVER (ORDER BY D_ADDL_RISK.TB_PAM_UID ASC, D_ADDL_RISK.SEQ_NBR ASC) AS RowNum
                                     FROM D_ADDL_RISK
                                  )
                                  SELECT *
                                  FROM PaginatedResults
                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM D_ADDL_RISK;',
           'COMPOSITE_KEY',
           'RowNum, COMPOSITE_KEY, D_ADDL_RISK_KEY, D_ADDL_RISK_GROUP_KEY',
           1
       ),
       (
           'D_DISEASE_SITE',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                                     SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,ISNULL(SEQ_NBR,1)) AS COMPOSITE_KEY, D_DISEASE_SITE.*,
                                            ROW_NUMBER() OVER (ORDER BY D_DISEASE_SITE.TB_PAM_UID ASC, D_DISEASE_SITE.SEQ_NBR ASC) AS RowNum
                                     FROM D_DISEASE_SITE
                                  )
                                  SELECT *
                                  FROM PaginatedResults
                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM D_DISEASE_SITE;',
           'COMPOSITE_KEY',
           'RowNum, COMPOSITE_KEY, D_DISEASE_SITE_KEY, D_DISEASE_SITE_GROUP_KEY',
           1
       ),
       (
           'D_GT_12_REAS',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                                     SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,ISNULL(SEQ_NBR,1)) AS COMPOSITE_KEY ,D_GT_12_REAS.*,
                                            ROW_NUMBER() OVER (ORDER BY D_GT_12_REAS.TB_PAM_UID ASC, D_GT_12_REAS.SEQ_NBR ASC) AS RowNum
                                     FROM D_GT_12_REAS
                                  )
                                  SELECT *
                                  FROM PaginatedResults
                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM D_GT_12_REAS;',
           'COMPOSITE_KEY',
           'RowNum, COMPOSITE_KEY, D_GT_12_REAS_KEY, D_GT_12_REAS_GROUP_KEY',
           1
       ),
       (
           'D_HC_PROV_TY_3',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                                     SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,ISNULL(SEQ_NBR,1)) AS COMPOSITE_KEY , D_HC_PROV_TY_3.*,
                                            ROW_NUMBER() OVER (ORDER BY D_HC_PROV_TY_3.TB_PAM_UID ASC, D_HC_PROV_TY_3.SEQ_NBR ASC) AS RowNum
                                     FROM D_HC_PROV_TY_3
                                  )
                                  SELECT *
                                  FROM PaginatedResults
                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM D_HC_PROV_TY_3;',
           'COMPOSITE_KEY',
           'RowNum, COMPOSITE_KEY, D_HC_PROV_TY_3_KEY, D_HC_PROV_TY_3_GROUP_KEY',
           1
       ),
       (
           'D_MOVE_CNTRY',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                                     SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,ISNULL(SEQ_NBR,1)) AS COMPOSITE_KEY , D_MOVE_CNTRY.*,
                                            ROW_NUMBER() OVER (ORDER BY D_MOVE_CNTRY.TB_PAM_UID ASC, D_MOVE_CNTRY.SEQ_NBR ASC) AS RowNum
                                     FROM D_MOVE_CNTRY
                                  )
                                  SELECT *
                                  FROM PaginatedResults
                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM D_MOVE_CNTRY;',
           'COMPOSITE_KEY',
           'RowNum, COMPOSITE_KEY, D_MOVE_CNTRY_KEY, D_MOVE_CNTRY_GROUP_KEY',
           1
       ),
       (
           'D_MOVE_CNTY',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                                     SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,ISNULL(SEQ_NBR,1)) AS COMPOSITE_KEY , D_MOVE_CNTY.*,
                                            ROW_NUMBER() OVER (ORDER BY D_MOVE_CNTY.TB_PAM_UID ASC, D_MOVE_CNTY.SEQ_NBR ASC) AS RowNum
                                     FROM D_MOVE_CNTY
                                  )
                                  SELECT *
                                  FROM PaginatedResults
                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM D_MOVE_CNTY;',
           'COMPOSITE_KEY',
           'RowNum, COMPOSITE_KEY, D_MOVE_CNTY_KEY, D_MOVE_CNTY_GROUP_KEY',
           1
       ),
       (
           'D_MOVE_STATE',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                                     SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,ISNULL(SEQ_NBR,1)) AS COMPOSITE_KEY ,  D_MOVE_STATE.*,
                                            ROW_NUMBER() OVER (ORDER BY D_MOVE_STATE.TB_PAM_UID ASC, D_MOVE_STATE.SEQ_NBR ASC) AS RowNum
                                     FROM D_MOVE_STATE
                                  )
                                  SELECT *
                                  FROM PaginatedResults
                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM D_MOVE_STATE;',
           'COMPOSITE_KEY',
           'RowNum, COMPOSITE_KEY, D_MOVE_STATE_KEY, D_MOVE_STATE_GROUP_KEY',
           1
       ),
       (
           'D_MOVED_WHERE',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                                     SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,ISNULL(SEQ_NBR,1)) AS COMPOSITE_KEY ,  D_MOVED_WHERE.*,
                                            ROW_NUMBER() OVER (ORDER BY D_MOVED_WHERE.TB_PAM_UID ASC, D_MOVED_WHERE.SEQ_NBR ASC) AS RowNum
                                     FROM D_MOVED_WHERE
                                  )
                                  SELECT *
                                  FROM PaginatedResults
                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM D_MOVED_WHERE;',
           'COMPOSITE_KEY',
           'RowNum, COMPOSITE_KEY, D_MOVED_WHERE_KEY, D_MOVED_WHERE_GROUP_KEY',
           1
       ),
       (
           'D_OUT_OF_CNTRY',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                                     SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,ISNULL(SEQ_NBR,1)) AS COMPOSITE_KEY ,  D_OUT_OF_CNTRY.*,
                                            ROW_NUMBER() OVER (ORDER BY D_OUT_OF_CNTRY.TB_PAM_UID ASC, D_OUT_OF_CNTRY.SEQ_NBR ASC) AS RowNum
                                     FROM D_OUT_OF_CNTRY
                                  )
                                  SELECT *
                                  FROM PaginatedResults
                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM D_OUT_OF_CNTRY;',
           'COMPOSITE_KEY',
           'RowNum, COMPOSITE_KEY, D_OUT_OF_CNTRY_KEY, D_OUT_OF_CNTRY_GROUP_KEY',
           1
       ),
       (
           'D_PCR_SOURCE',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                                     SELECT DISTINCT CONVERT(VARCHAR,VAR_PAM_UID)+''_''+CONVERT(VARCHAR,ISNULL(SEQ_NBR,1)) AS COMPOSITE_KEY , D_PCR_SOURCE.*,
                                            ROW_NUMBER() OVER (ORDER BY D_PCR_SOURCE.VAR_PAM_UID ASC, D_PCR_SOURCE.SEQ_NBR ASC) AS RowNum
                                     FROM D_PCR_SOURCE
                                  )
                                  SELECT *
                                  FROM PaginatedResults
                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM D_PCR_SOURCE;',
           'COMPOSITE_KEY',
           'RowNum, COMPOSITE_KEY, D_PCR_SOURCE_KEY, D_PCR_SOURCE_GROUP_KEY',
           1
       ),
       (
           'D_RASH_LOC_GEN',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                                     SELECT DISTINCT CONVERT(VARCHAR,VAR_PAM_UID)+''_''+CONVERT(VARCHAR,ISNULL(SEQ_NBR,1)) AS COMPOSITE_KEY ,  D_RASH_LOC_GEN.*,
                                            ROW_NUMBER() OVER (ORDER BY D_RASH_LOC_GEN.VAR_PAM_UID ASC, D_RASH_LOC_GEN.SEQ_NBR ASC) AS RowNum
                                     FROM D_RASH_LOC_GEN
                                  )
                                  SELECT *
                                  FROM PaginatedResults
                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM D_RASH_LOC_GEN;',
           'COMPOSITE_KEY',
           'RowNum, COMPOSITE_KEY, D_RASH_LOC_GEN_KEY, D_RASH_LOC_GEN_GROUP_KEY',
           1
       ),
       (
           'D_SMR_EXAM_TY',
           'RDB',
           'RDB_MODERN',
           'WITH PaginatedResults AS (
                                     SELECT DISTINCT CONVERT(VARCHAR,TB_PAM_UID)+''_''+CONVERT(VARCHAR,ISNULL(SEQ_NBR,1)) AS COMPOSITE_KEY ,  D_SMR_EXAM_TY.*,
                                            ROW_NUMBER() OVER (ORDER BY D_SMR_EXAM_TY.TB_PAM_UID ASC, D_SMR_EXAM_TY.SEQ_NBR ASC) AS RowNum
                                     FROM D_SMR_EXAM_TY
                                  )
                                  SELECT *
                                  FROM PaginatedResults
                                  WHERE RowNum BETWEEN :startRow AND :endRow;',
           'SELECT COUNT(*)
                                  FROM D_SMR_EXAM_TY;',
           'COMPOSITE_KEY',
           'RowNum, COMPOSITE_KEY, D_SMR_EXAM_TY_KEY, D_SMR_EXAM_TY_GROUP_KEY',
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
           'INVESTIGATION_LOCAL_ID',
           'RowNum, INVESTIGATION_LOCAL_ID, INVESTIGATION_KEY',
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
           'INVESTIGATION_LOCAL_ID',
           'RowNum, INVESTIGATION_LOCAL_ID, INVESTIGATION_KEY',
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
           'RowNum, INVESTIGATION_KEY, L_11310430LDF_SANDIEGO, L_11310752newfield_2_5_1_2_3_,
           L_11310760LDF_added_after_tes, L_11311018Confirmation_method, L_11311305newdemofield123,
           L_11311544retestbug, L_11485487retest_bug2, L_11485535may16field, L_11485561LDF_added_after_tes,
           L_11310430LDF_SANDIEGO, L_11311544_retestbug, L_11485561_LDF_added_after)te',
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
           'LOCAL_ID',
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
              FROM COVID_LAB_CELR_DATAMART;',
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
       );

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