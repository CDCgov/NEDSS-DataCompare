package gov.cdc.datacomparecron.service;

import gov.cdc.datacomparecron.service.interfaces.IDataCompareApiService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class DataCompareApiService implements IDataCompareApiService {
    private static final Logger logger = LoggerFactory.getLogger(DataCompareApiService.class);

    @Value("${data_compare.endpoint_compare}")
    private String compareEndpoint;

    private final RestTemplate restTemplate;
    private final TokenService tokenService;

    public DataCompareApiService(RestTemplate restTemplate, TokenService tokenService) {
        this.restTemplate = restTemplate;
        this.tokenService = tokenService;
    }
    @Override
    public void compareData(boolean runNow, boolean autoApply) {
        try {
            String token = tokenService.getToken();
            HttpHeaders headers = new HttpHeaders();
            headers.add("Authorization", "Bearer " + token);
            headers.add("runNowMode", String.valueOf(runNow));
            headers.add("autoApply", String.valueOf(autoApply));

            String url = compareEndpoint;
            HttpEntity<String> entity = new HttpEntity<>(headers);

            restTemplate.exchange(url, HttpMethod.GET, entity, String.class);
            logger.info("Data comparison completed successfully");
        } catch (Exception e) {
            logger.error("Error during data comparison", e);
            throw new RuntimeException("Failed to complete data comparison", e);
        }
    }
}