package gov.cdc.datacompareprocessor.service.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PullerEventModel {
    public String firstLayerRdbFolderName;
    public String firstLayerRdbModernFolderName;
    public String secondLayerFolderName;
    public String thirdLayerFolderName;
    public String fileName;
    public Integer rdbMaxIndex;
    public Integer rdbModernMaxIndex;
    public String keyColumn;
    public String ignoreColumns;
    public Long logId;
}
