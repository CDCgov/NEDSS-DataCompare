package gov.cdc.datacompareprocessor.service.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DifferentModel {
    public String keyColumn;
    public String key;
    public String table;
    public String missingColumn;
    public String nullValueColumns;
    public String differentColumnAndValue;
}
