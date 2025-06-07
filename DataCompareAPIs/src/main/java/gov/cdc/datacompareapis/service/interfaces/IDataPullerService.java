package gov.cdc.datacompareapis.service.interfaces;

public interface IDataPullerService {
     void pullingData(int pullLimit, boolean runNowMode, boolean autoApply);
}
