package gov.cdc.datacomparecron.service;

import gov.cdc.datacomparecron.service.interfaces.IDataCompareService;
import gov.cdc.datacomparecron.service.interfaces.ITokenService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class DataCompareService implements IDataCompareService {
    private static final Logger logger = LoggerFactory.getLogger(DataCompareService.class);

    @Value("${data_exchange.endpoint_compare}")
    private String compareEndpoint;

    private final RestTemplate restTemplate;
    private final ITokenService tokenService;

    public DataCompareService(RestTemplate restTemplate, ITokenService tokenService) {
        this.restTemplate = restTemplate;
        this.tokenService = tokenService;
    }

    @Scheduled(cron = "${scheduler.cron}")
    public void scheduleDataCompare() {
        logger.info("Starting scheduled data comparison");
        compareData(false);
    }

    public void compareData(boolean runNow) {
        try {
            String token = tokenService.getToken();
            HttpHeaders headers = new HttpHeaders();
            headers.add("Authorization", "Bearer " + token);

            String url = compareEndpoint + "?runNow=" + runNow;
            HttpEntity<String> entity = new HttpEntity<>(headers);

            restTemplate.exchange(url, HttpMethod.GET, entity, String.class);
            logger.info("Data comparison completed successfully");
        } catch (Exception e) {
            logger.error("Error during data comparison", e);
            throw new RuntimeException("Failed to complete data comparison", e);
        }
    }
}
