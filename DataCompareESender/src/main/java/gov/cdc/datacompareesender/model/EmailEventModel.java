package gov.cdc.datacompareesender.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class EmailEventModel {
    private String bucketName;
    private String rdbPath;
    private String rdbModernPath;
    private String differentFile;
    private String fileName;
}
