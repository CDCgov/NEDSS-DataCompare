package gov.cdc.datacompareapis.repository.dataCompare.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
@Entity
@Table(name = "Data_Compare_Log")
public class DataCompareLog {

    @Id
    @Column(name = "dc_log_id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long dcLogId;

    @Column(name = "config_id")
    private Long configId;

    @Column(name = "database_table", nullable = false)
    private String tableName;


    @Column(name = "start_date_time")
    private Timestamp startDateTime;

    @Column(name = "end_date_time")
    private Timestamp endDateTime;

    @Column(name = "file_name")
    private String fileName;

    @Column(name = "file_location", length = 1000)
    private String fileLocation;

    @Column(name = "status", length = 20)
    private String status;

    @Column(name = "status_desc")
    private String statusDesc;

    @Column(name = "run_by_user")
    private String runByUser;

    @Column(name = "rows_compared")
    private long rowsCompared;

    @Column(name = "batch_id")
    private long batchId;
}