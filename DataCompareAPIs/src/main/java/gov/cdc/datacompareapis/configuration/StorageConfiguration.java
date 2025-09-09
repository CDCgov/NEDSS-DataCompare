package gov.cdc.datacompareapis.configuration;

import gov.cdc.datacompareapis.service.interfaces.IStorageDataService;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

@Configuration
public class StorageConfiguration {

    @Value("${cloud.provider:AWS}")
    private String cloudProvider;

    @Bean
    @Primary
    public IStorageDataService storageDataService(
            @Qualifier("awsS3") IStorageDataService awsS3Service,
            @Qualifier("azureBlob") IStorageDataService azureBlobService) {

        if ("AZURE".equalsIgnoreCase(cloudProvider)) {
            return azureBlobService;
        }
        // Default to AWS
        return awsS3Service;
    }
}
