package gov.cdc.datacompareapis.repository.dataCompare.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
@Table(name = "Data_Compare_Config")
@Entity
public class DataCompareConfig {

    @Id
    @Column(name = "config_id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long configId;

    @Column(name = "table_name", length = 200)
    private String tableName;

    @Column(name = "source_db", length = 100)
    private String sourceDb;

    @Column(name = "target_db", length = 100)
    private String targetDb;



    @Column(name = "query")
    private String query;

    @Column(name = "query_count")
    private String queryCount;

    @Column(name = "query_rtr")
    private String queryRtr;

    @Column(name = "query_rtr_count")
    private String queryRtrCount;




    @Column(name = "key_column_list")
    private String keyColumns;

    @Column(name = "ignore_column_list")
    private String ignoreColumns;

    @Column(name = "compare")
    private Boolean compare;

    @Column(name = "run_now")
    private Boolean runNow;


    @Column(name = "created_datetime")
    private Timestamp createdDatetime;

    @Column(name = "updated_datetime")
    private Timestamp updatedDatetime;

    @Column(name = "created_by", length = 50)
    private String createdBy;

    @Column(name = "updated_by", length = 50)
    private String updatedBy;
}
