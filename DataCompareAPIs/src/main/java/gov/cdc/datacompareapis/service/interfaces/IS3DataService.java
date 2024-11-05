package gov.cdc.datacompareapis.service.interfaces;

import java.sql.Timestamp;

public interface IS3DataService {
    String persistToS3MultiPart(String domain, String records, String fileName, Timestamp persistingTimestamp, int index);
}
