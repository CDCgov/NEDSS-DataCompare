package gov.cdc.datacomparecron.service;

import gov.cdc.datacomparecron.service.interfaces.IDataCompareCronService;
import gov.cdc.datacomparecron.service.interfaces.IDataCompareApiService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Service
public class DataCompareCronService implements IDataCompareCronService {
    private static final Logger logger = LoggerFactory.getLogger(DataCompareCronService.class);

    @Value("${scheduler.run_now:false}")
    private boolean defaultRunNow;

    private final IDataCompareApiService apiService;

    public DataCompareCronService(IDataCompareApiService apiService) {
        this.apiService = apiService;
    }

    @Scheduled(cron = "${scheduler.cron}", zone = "${scheduler.zone}")
    public void scheduleDataCompare() {
        scheduleDataCompare(defaultRunNow);
    }

    @Override
    public void scheduleDataCompare(boolean runNow) {
        logger.info("Starting scheduled data comparison with runNow: {}", runNow);
        apiService.compareData(runNow);
    }
}