package gov.cdc.datacompareesender.model;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
public class EmailEventModel {
    private String fileName;
    private String reportPath; // S3 path for the comparison report
    private List<String> recipients;
    private Map<String, Long> discrepancies;
    private LocalDateTime comparisonTime;
}