IF COL_LENGTH('NBS_Data_Internal.dbo.Data_Compare_Config', 'target_table_name') IS NULL
BEGIN
ALTER TABLE Data_Compare_Config
    ADD target_table_name VARCHAR(200) NULL;
END;

IF COL_LENGTH('NBS_Data_Internal.dbo.Data_Compare_Config', 'target_query') IS NULL
BEGIN
ALTER TABLE Data_Compare_Config
    ADD target_query VARCHAR(MAX) NULL;
END;

IF COL_LENGTH('NBS_Data_Internal.dbo.Data_Compare_Config', 'target_query_count') IS NULL
BEGIN
ALTER TABLE Data_Compare_Config
    ADD target_query_count VARCHAR(MAX) NULL;
END;