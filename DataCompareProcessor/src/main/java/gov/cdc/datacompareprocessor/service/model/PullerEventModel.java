package gov.cdc.datacompareprocessor.service.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PullerEventModel {
    public String firstLayerRdbFolderName;
    public String firstLayerRdbModernFolderName;
    public String firstLayerOdseSourceFolderName;
    public String firstLayerOdseTargetFolderName;
    public String secondLayerFolderName;
    public String thirdLayerFolderName;
    public String sourceFileName;
    public String targetFileName;
    public Integer rdbMaxIndex;
    public Integer rdbModernMaxIndex;
    public Integer odseSourceMaxIndex;
    public Integer odseTargetMaxIndex;
    public String keyColumn;
    public String ignoreColumns;
    public Long logIdRdb;
    public Long logIdRdbModern;
    public Long logIdOdseSource;
    public Long logIdOdseTarget;
}
