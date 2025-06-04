package gov.cdc.datacompareprocessor.repository.dataCompare.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
@Table(name = "Data_Compare_Batch")
@Entity
public class DataCompareBatch {
    @Id
    @Column(name = "batch_id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long batchId;

    @Column(name = "batch_name", length = 200)
    private String batchName;

    @Column(name = "created_datetime")
    private Timestamp createdDatetime;

    @Column(name = "updated_datetime")
    private Timestamp updatedDatetime;

    @Column(name = "created_by", length = 50)
    private String createdBy;

    @Column(name = "updated_by", length = 50)
    private String updatedBy;
}
