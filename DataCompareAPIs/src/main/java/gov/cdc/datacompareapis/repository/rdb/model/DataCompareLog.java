package gov.cdc.datacompareapis.repository.rdb.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
@Entity
@Table(name = "DataCompare_Log")
public class DataCompareLog {

    @Id
    @Column(name = "dc_log_id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long dcLogId;

    @Column(name = "config_id", nullable = false)
    private Long configId;

    @Column(name = "database", length = 200)
    private String database;

    @Column(name = "start_date_time")
    private Timestamp startDateTime;

    @Column(name = "end_date_time")
    private Timestamp endDateTime;

    @Column(name = "file_name", length = 100)
    private String fileName;

    @Column(name = "file_location", length = 1000)
    private String fileLocation;

    @Column(name = "status", length = 20)
    private String status;

    @Column(name = "status_desc", length = 2000)
    private String statusDesc;
}