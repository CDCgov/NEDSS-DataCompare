package gov.cdc.datacompareapis.repository.rdb.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
@Table(name = "Data_Compare_Config")
@Entity
public class DataCompareConfig {

//    @Id
//    @Column(name = "config_id")
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    private Long configId;

    @Id
    @Column(name = "table_name", length = 200)
    private String tableName;

    @Column(name = "source_db", length = 100)
    private String sourceDb;

    @Column(name = "target_db", length = 100)
    private String targetDb;



    @Column(name = "rdb_sql_query")
    private String rdbSqlQuery;

    @Column(name = "rdb_modern_sql_query")
    private String rdbModernSqlQuery;

    @Column(name = "rdb_sql_count_query")
    private String rdbSqlCountQuery;

    @Column(name = "rdb_modern_sql_count_query")
    private String rdbModernSqlCountQuery;

    @Column(name = "key_column")
    private String keyColumn;

    @Column(name = "ignore_columns")
    private String ignoreColumns;

    @Column(name = "compare")
    private Boolean compare;

    @Column(name = "file_type", length = 20)
    private String fileType;

    @Column(name = "storage_location", length = 200)
    private String storageLocation;

    @Column(name = "created_datetime")
    private Timestamp createdDatetime;

    @Column(name = "updated_datetime")
    private Timestamp updatedDatetime;

    @Column(name = "created_by", length = 50)
    private String createdBy;

    @Column(name = "updated_by", length = 50)
    private String updatedBy;
}
