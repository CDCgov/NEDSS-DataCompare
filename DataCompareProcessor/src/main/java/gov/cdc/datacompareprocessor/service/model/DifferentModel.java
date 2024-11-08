package gov.cdc.datacompareprocessor.service.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DifferentModel {
    public String rdbKey;
    public String rdbModernKey;
    public String table;
    public String differentColumnAndValue;
}
