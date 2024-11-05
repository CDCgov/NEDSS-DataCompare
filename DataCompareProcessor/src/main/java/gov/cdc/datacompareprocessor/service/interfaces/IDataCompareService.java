package gov.cdc.datacompareprocessor.service.interfaces;

import gov.cdc.datacompareprocessor.service.model.PullerEventModel;

public interface IDataCompareService {
    void processingData(PullerEventModel pullerEventModel);
}
