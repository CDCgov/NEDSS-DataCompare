package gov.cdc.datacompareapis.service.model;

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
}
