package gov.cdc.datacompareapis.service.interfaces;

import gov.cdc.datacompareapis.exception.DataCompareException;

public interface IDataPullerService {
     void pullingData(int pullLimit, boolean runNowMode);
     void pullDataForDataIngestionValidation(long nbsInterfaceUid1, long nbsInterfaceUid2) throws DataCompareException;
}
