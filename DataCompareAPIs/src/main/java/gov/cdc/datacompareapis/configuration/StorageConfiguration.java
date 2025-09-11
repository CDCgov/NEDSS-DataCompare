package gov.cdc.datacompareapis.configuration;

import gov.cdc.datacompareapis.service.interfaces.IStorageDataService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

@Configuration
public class StorageConfiguration {

    private static final Logger logger = LoggerFactory.getLogger(StorageConfiguration.class);

    @Value("${cloud.provider:AWS}")
    private String cloudProvider;

    @Bean
    @Primary
    public IStorageDataService storageDataService(
            @Autowired(required = false) @Qualifier("awsS3") IStorageDataService awsS3Service,
            @Autowired(required = false) @Qualifier("azureBlob") IStorageDataService azureBlobService) {

        logger.info("=== STORAGE PROVIDER CONFIGURATION (APIs) ===");
        logger.info("Configured cloud provider: {}", cloudProvider);
        
        if ("AZURE".equalsIgnoreCase(cloudProvider)) {
            if (azureBlobService == null) {
                logger.error("Azure Blob service is not available but AZURE provider is configured!");
                throw new IllegalStateException("Azure Blob service is not available. Check your configuration.");
            }
            logger.info("Selected Azure Blob Storage service as primary storage provider");
            logger.info("Azure Blob service class: {}", azureBlobService.getClass().getSimpleName());
            logger.info("=== END STORAGE PROVIDER CONFIGURATION (APIs) ===");
            return azureBlobService;
        }
        
        // Default to AWS
        if (awsS3Service == null) {
            logger.error("AWS S3 service is not available!");
            throw new IllegalStateException("AWS S3 service is not available. Check your configuration.");
        }
        logger.info("Selected AWS S3 service as primary storage provider (default)");
        logger.info("AWS S3 service class: {}", awsS3Service.getClass().getSimpleName());
        logger.info("=== END STORAGE PROVIDER CONFIGURATION (APIs) ===");
        
        return awsS3Service;
    }
}
