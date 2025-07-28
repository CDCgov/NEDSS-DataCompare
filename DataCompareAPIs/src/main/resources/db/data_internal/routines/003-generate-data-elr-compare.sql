DELETE FROM Data_Compare_Config
where source_db = 'NBS_ODSE_LEGACY';
INSERT INTO Data_Compare_Config
(
    table_name, source_db, target_db, query, query_count, key_column_list, ignore_column_list, compare
)
VALUES
    (
        'Observation', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY Observation.observation_uid asc) AS compare_id,
        *
        from Observation
        where observation_uid = :observationUid;',
        '',
        'compare_id',
        'observation_uid, add_time, add_user_id, last_chg_time, last_chg_user_id, record_status_time, version_ctrl_nbr, rpt_to_state_time',
        1
    ),
    (
        'Obs_value_coded', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY Obs_value_coded.observation_uid asc) AS compare_id,
        *
        from Obs_value_coded
        where observation_uid = :observationUid;',
        '',
        'compare_id',
        'observation_uid',
        1
    ),
    (
        'Obs_value_numeric', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY Obs_value_numeric.observation_uid asc) AS compare_id,
        *
        from Obs_value_numeric
        where observation_uid = :observationUid;',
        '',
        'compare_id',
        'observation_uid',
        1
    ),
    (
        'Obs_value_date', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY Obs_value_date.observation_uid asc) AS compare_id,
        *
        from Obs_value_date
        where observation_uid = :observationUid;',
        '',
        'compare_id',
        'observation_uid',
        1
    ),
    (
        'Obs_value_txt', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY Obs_value_txt.observation_uid asc) AS compare_id,
        *
        from Obs_value_txt
        where observation_uid = :observationUid;',
        '',
        'compare_id',
        'observation_uid',
        1
    ),
    (
        'observation_interp', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY observation_interp.observation_uid asc) AS compare_id,
        *
        from observation_interp
        where observation_uid = :observationUid;',
        '',
        'compare_id',
        'observation_uid',
        1
    ),
    (
        'observation_reason', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY observation_reason.observation_uid asc) AS compare_id,
        *
        from observation_reason
        where observation_uid = :observationUid;',
        '',
        'compare_id',
        'observation_uid',
        1
    ),
    (
        'Act', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY Act.act_uid asc) AS compare_id,
        *
        from Act
        where act_uid = :observationUid;',
        '',
        'compare_id',
        'act_uid',
        1
    ),
    (
        'Act_id', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY Act_id.act_uid asc) AS compare_id,
        *
        from Act_id
        where act_uid = :observationUid;',
        '',
        'compare_id',
        'act_uid',
        1
    ),
    (
        'Act_relationship', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'SELECT
        ROW_NUMBER() OVER (ORDER BY Act_relationship.target_act_uid ASC) AS compare_id,
        *
        FROM Act_relationship
        WHERE source_act_uid = :observationUid
        OR target_act_uid = :observationUid;',
        '',
        'compare_id',
        'target_act_uid, source_act_uid, add_time, last_chg_time, record_status_time, from_time, status_time, last_chg_user_id',
        1
    ),
    (
        'participation', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY type_cd asc, subject_class_cd asc, cd asc, subject_entity_uid asc) AS compare_id,
        *
        from participation
        where act_uid = :observationUid;',
        '',
        'compare_id',
        'act_uid, add_time, add_user_id, last_chg_time, subject_entity_uid',
        1
    ),
    (
        'entity', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY class_cd asc, entity_uid asc) AS compare_id,
        entity.* from entity
        inner join participation
        on entity.entity_uid = participation.subject_entity_uid
        where participation.act_uid = :observationUid;',
        '',
        'compare_id',
        '',
        1
    ),
    (
        'entity_id', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY assigning_authority_cd asc, entity_uid asc) AS compare_id,
        * from entity_id where
        entity_uid in
        (select entity.entity_uid from entity
        inner join participation
        on entity.entity_uid = participation.subject_entity_uid
        where participation.act_uid = :observationUid);',
        '',
        'compare_id',
        'entity_uid, add_time, add_user_id',
        1
    ),
    (
        'entity_locator_participation', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY entity_uid asc) AS compare_id,
        * from entity_locator_participation where
        entity_uid in
        (select entity.entity_uid from entity
        inner join participation
        on entity.entity_uid = participation.subject_entity_uid
        where participation.act_uid = :observationUid);',
        '',
        'compare_id',
        'entity_uid, locator_uid, add_time, add_user_id, last_chg_time, last_chg_user_id, record_status_time, status_time, as_of_date',
        1
    ),
    (
        'Tele_locator', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY tele_locator_uid asc) AS compare_id,
        * from Tele_locator
        where tele_locator_uid in
        (
        select entity_locator_participation.locator_uid from entity_locator_participation where
        entity_uid in
        (select entity.entity_uid from entity
        inner join participation
        on entity.entity_uid = participation.subject_entity_uid
        where participation.act_uid = :observationUid)
        );',
        '',
        'compare_id',
        '',
        1
    ),
    (
        'Postal_locator', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY postal_locator_uid asc) AS compare_id,
        * from Postal_locator
        where postal_locator_uid in
        (
        select entity_locator_participation.locator_uid from entity_locator_participation where
        entity_uid in
        (select entity.entity_uid from entity
        inner join participation
        on entity.entity_uid = participation.subject_entity_uid
        where participation.act_uid = :observationUid)
        );',
        '',
        'compare_id',
        'postal_locator_uid, add_time, add_user_id, record_status_time',
        1
    ),
    (
        'organization', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY organization_uid asc) AS compare_id,
        * from organization
        where organization_uid in
        (select entity.entity_uid from entity
        inner join participation
        on entity.entity_uid = participation.subject_entity_uid
        where participation.act_uid = :observationUid);',
        '',
        'compare_id',
        'organization_uid, add_time, add_user_id, last_chg_time, last_chg_user_id, record_status_time, status_time',
        1
    ),
    (
        'Organization_name', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY organization_uid asc) AS compare_id,
        * from Organization_name
        where organization_uid in
        (select organization.organization_uid from organization
        where organization_uid in
        (select entity.entity_uid from entity
        inner join participation
        on entity.entity_uid = participation.subject_entity_uid
        where participation.act_uid = :observationUid));',
        '',
        'compare_id',
        'organization_uid',
        1
    ),
    (
        'person', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY cd asc, person_uid asc) AS compare_id,
        * from person
        where person_uid in
        (select entity.entity_uid from entity
        inner join participation
        on entity.entity_uid = participation.subject_entity_uid
        where participation.act_uid = :observationUid);',
        '',
        'compare_id',
        'person_uid, add_time, add_user_id, last_chg_time, last_chg_user_id, record_status_time, status_time, as_of_date_admin, as_of_date_ethnicity, as_of_date_general, as_of_date_morbidity, as_of_date_sex, person_parent_uid',
        1
    ),
    (
        'Person_ethnic_group', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY person_uid asc) AS compare_id,
        * from Person_ethnic_group
        where person_uid in
        (select person.person_uid from person
        where person_uid in
        (select entity.entity_uid from entity
        inner join participation
        on entity.entity_uid = participation.subject_entity_uid
        where participation.act_uid = :observationUid));',
        '',
        'compare_id',
        '',
        1
    ),
    (
        'person_name', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY person_uid asc) AS compare_id,
        * from person_name
        where person_uid in
        (select person.person_uid from person
        where person_uid in
        (select entity.entity_uid from entity
        inner join participation
        on entity.entity_uid = participation.subject_entity_uid
        where participation.act_uid = :observationUid));',
        '',
        'compare_id',
        'person_uid, add_time, last_chg_time, record_status_time, status_time, as_of_date',
        1
    ),
    (
        'person_race', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY person_uid asc) AS compare_id,
        * from person_race
        where person_uid in
        (select person.person_uid from person
        where person_uid in
        (select entity.entity_uid from entity
        inner join participation
        on entity.entity_uid = participation.subject_entity_uid
        where participation.act_uid = :observationUid));',
        '',
        'compare_id',
        'person_uid, add_time, add_user_id, last_chg_time, as_of_date',
        1
    ),
    (
        'role', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY subject_entity_uid asc) AS compare_id,
        * from role
        where subject_entity_uid in
        (select entity.entity_uid from entity
        inner join participation
        on entity.entity_uid = participation.subject_entity_uid
        where participation.act_uid = :observationUid);',
        '',
        'compare_id',
        'subject_entity_uid, add_time, effective_from_time, effective_to_time, status_time',
        1
    ),
    (
        'material', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY material_uid asc) AS compare_id,
        * from material
        where material_uid in
        (select entity.entity_uid from entity
        inner join participation
        on entity.entity_uid = participation.subject_entity_uid
        where participation.act_uid = :observationUid);',
        '',
        'compare_id',
        'material_uid, add_time, add_user_id, last_chg_time, last_chg_user_id, record_status_time, status_time',
        1
    ),
    (
        'public_health_case', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
        'select
        ROW_NUMBER() OVER (ORDER BY public_health_case_uid asc) AS compare_id,
        *
        from public_health_case
        where public_health_case_uid = :observationUid;',
        '',
        'compare_id',
        '',
        1
    )
--        ,
--     (
--         'NBS_act_entity', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
--         'select
--         ROW_NUMBER() OVER (ORDER BY nbs_act_entity_uid asc) AS compare_id,
--         *
--         from NBS_act_entity
--         where act_uid = :observationUid;',
--         '',
--         'compare_id',
--         '',
--         1
--     ),
--     (
--         'nbs_answer', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
--         'select
--         ROW_NUMBER() OVER (ORDER BY nbs_answer_uid asc) AS compare_id,
--         *
--         from nbs_answer
--         where act_uid = :observationUid;',
--         '',
--         'compare_id',
--         '',
--         1
--     ),
--     (
--         'nbs_case_answer', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
--         'select
--         ROW_NUMBER() OVER (ORDER BY nbs_case_answer_uid asc) AS compare_id,
--         *
--         from nbs_case_answer
--         where act_uid = :observationUid;',
--         '',
--         'compare_id',
--         '',
--         1
--     )
--    ,
--     (
--         'Notification', 'NBS_ODSE_LEGACY', 'NBS_ODSE_RTI',
--         'select
--         ROW_NUMBER() OVER (ORDER BY notification_uid asc) AS compare_id,
--         *
--         from Notification
--         where notification_uid = :observationUid;',
--         '',
--         'compare_id',
--         '',
--         1
--     )
