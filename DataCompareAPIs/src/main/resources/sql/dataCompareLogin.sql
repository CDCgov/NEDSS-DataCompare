CREATE LOGIN data_compare WITH PASSWORD = 'compare';

USE NBS_DATA_INTERNAL;
CREATE USER data_compare FOR LOGIN data_compare;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO data_compare;

USE RDB;
CREATE USER data_compare FOR LOGIN data_compare;
GRANT SELECT ON SCHEMA::dbo TO data_compare;

USE rdb_modern;
CREATE USER data_compare FOR LOGIN data_compare;
GRANT SELECT ON SCHEMA::dbo TO data_compare;
