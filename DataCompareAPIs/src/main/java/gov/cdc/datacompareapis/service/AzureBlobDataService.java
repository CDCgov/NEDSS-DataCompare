package gov.cdc.datacompareapis.service;

import com.azure.core.credential.AzureSasCredential;
import com.azure.core.credential.TokenCredential;
import com.azure.core.util.BinaryData;
import com.azure.identity.DefaultAzureCredentialBuilder;
import com.azure.storage.blob.BlobClient;
import com.azure.storage.blob.BlobContainerClient;
import com.azure.storage.blob.BlobServiceClient;
import com.azure.storage.blob.BlobServiceClientBuilder;
import gov.cdc.datacompareapis.exception.DataCompareException;
import gov.cdc.datacompareapis.service.interfaces.IStorageDataService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;


import java.sql.Timestamp;
import java.text.SimpleDateFormat;

import static gov.cdc.datacompareapis.constant.ConstantValue.LOG_SUCCESS;

@Service("azureBlob")
@ConditionalOnProperty(name = "cloud.provider", havingValue = "AZURE", matchIfMissing = false)
public class AzureBlobDataService implements IStorageDataService {
    private static final Logger logger = LoggerFactory.getLogger(AzureBlobDataService.class);

    @Value("${azure.blob.storage-account-name}")
    private String storageAccountName;

    @Value("${azure.blob.container-name}")
    private String containerName;

    @Value("${azure.blob.connection-string:}")
    private String connectionString;

    @Value("${azure.blob.sas-token:}")
    private String sasToken;

    @Value("${azure.blob.managed-identity.enabled:false}")
    private boolean managedIdentityEnabled;

    private final BlobServiceClient blobServiceClient;

    @Autowired
    public AzureBlobDataService(
            @Value("${azure.blob.storage-account-name}") String storageAccountName,
            @Value("${azure.blob.connection-string:}") String connectionString,
            @Value("${azure.blob.sas-token:}") String sasToken,
            @Value("${azure.blob.managed-identity.enabled:false}") boolean managedIdentityEnabled
    ) throws DataCompareException {
        this.storageAccountName = storageAccountName;
        this.connectionString = connectionString;
        this.sasToken = sasToken;
        this.managedIdentityEnabled = managedIdentityEnabled;

        BlobServiceClientBuilder builder = new BlobServiceClientBuilder();

        if (managedIdentityEnabled) {
            logger.info("Creating Azure Blob Data Service with Managed Identity enabled");
            TokenCredential credential = new DefaultAzureCredentialBuilder().build();
            builder.endpoint(String.format("https://%s.blob.core.windows.net", storageAccountName))
                    .credential(credential);
        } else if (StringUtils.hasText(connectionString)) {
            logger.info("Creating Azure Blob Data Service with connection string");
            builder.connectionString(connectionString);
        } else if (StringUtils.hasText(sasToken)) {
            logger.info("Creating Azure Blob Data Service with SAS token");
            String token = sasToken.startsWith("?") ? sasToken.substring(1) : sasToken;
            builder.endpoint(String.format("https://%s.blob.core.windows.net", storageAccountName))
                    .credential(new AzureSasCredential(token));
        } else {
            throw new DataCompareException("No Valid Azure Blob Storage authentication method found");
        }

        this.blobServiceClient = builder.buildClient();
    }

    public AzureBlobDataService(BlobServiceClient blobServiceClient) {
        // for unit tests
        this.blobServiceClient = blobServiceClient;
    }
    /**
     * Azure Blob Storage location naming
     * DOMAIN/TABLE/TIMESTAMP/TABLE_INDEX
     */
    public String persistMultiPart(String domain, String records, String fileName, Timestamp persistingTimestamp, int index) {
        logger.debug("AzureBlobDataService: Persisting data to Azure Blob - domain: {}, fileName: {}, index: {}, data size: {} bytes", 
                    domain, fileName, index, records.length());
        String log = LOG_SUCCESS;
        try {
            if (records.equalsIgnoreCase("[]") || records.isEmpty()) {
                throw new DataCompareException("No data to persist for table " + fileName);
            }
            String formattedTimestamp = new SimpleDateFormat("yyyyMMddHHmmss").format(persistingTimestamp);

            // Construct the file path: /filename/filename_timestamp.json
            String blobName = String.format("%s/%s/%s/%s_%s.json", domain, fileName, formattedTimestamp, fileName, index);
            
            // Get container client
            BlobContainerClient containerClient = blobServiceClient.getBlobContainerClient(containerName);
            
            // Get blob client
            BlobClient blobClient = containerClient.getBlobClient(blobName);
            
            // Upload data as binary data
            BinaryData binaryData = BinaryData.fromString(records);
            blobClient.upload(binaryData, true);

            logger.debug("AzureBlobDataService: Successfully persisted data to Azure Blob Storage: {}", blobName);
        } catch (Exception e) {
            logger.error("AzureBlobDataService: Error persisting data to Azure Blob Storage: {}", e.getMessage(), e);
            log = e.getMessage();
        }
        return log;
    }
}
