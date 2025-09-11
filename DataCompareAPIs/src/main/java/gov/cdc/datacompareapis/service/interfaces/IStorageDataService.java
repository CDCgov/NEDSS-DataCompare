package gov.cdc.datacompareapis.service.interfaces;

import java.sql.Timestamp;

public interface IStorageDataService {
    String persistMultiPart(String domain, String records, String fileName, Timestamp persistingTimestamp, int index);
}
