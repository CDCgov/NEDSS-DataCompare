package gov.cdc.datacompareprocessor.service;

import com.azure.core.credential.AzureSasCredential;
import com.azure.core.credential.TokenCredential;
import com.azure.core.util.BinaryData;
import com.azure.identity.DefaultAzureCredentialBuilder;
import com.azure.storage.blob.BlobClient;
import com.azure.storage.blob.BlobContainerClient;
import com.azure.storage.blob.BlobServiceClient;
import com.azure.storage.blob.BlobServiceClientBuilder;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;
import gov.cdc.datacompareprocessor.configuration.TimestampAdapter;
import gov.cdc.datacompareprocessor.exception.DataProcessorException;
import gov.cdc.datacompareprocessor.service.interfaces.IStorageDataPullerService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.sql.Timestamp;

@Service("azureBlob")
@ConditionalOnProperty(name = "cloud.provider", havingValue = "AZURE", matchIfMissing = false)
public class AzureBlobDataPullerService implements IStorageDataPullerService {
    private static final Logger logger = LoggerFactory.getLogger(AzureBlobDataPullerService.class);

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
    private final Gson gson;

    @Autowired
    public AzureBlobDataPullerService(
            @Value("${azure.blob.storage-account-name}") String storageAccountName,
            @Value("${azure.blob.connection-string:}") String connectionString,
            @Value("${azure.blob.sas-token:}") String sasToken,
            @Value("${azure.blob.managed-identity.enabled:false}") boolean managedIdentityEnabled
    ) throws DataProcessorException {
        this.storageAccountName = storageAccountName;
        this.connectionString = connectionString;
        this.sasToken = sasToken;
        this.managedIdentityEnabled = managedIdentityEnabled;

        BlobServiceClientBuilder builder = new BlobServiceClientBuilder();

        if (managedIdentityEnabled) {
            logger.info("Creating Azure Blob Data Puller Service with Managed Identity enabled");
            // MSI / DefaultAzureCredential (supports az login locally, and MSI on Azure)
            TokenCredential credential = new DefaultAzureCredentialBuilder().build();
            builder.endpoint(String.format("https://%s.blob.core.windows.net", storageAccountName))
                    .credential(credential);
        } else if (StringUtils.hasText(connectionString)) {
            logger.info("Creating Azure Blob Data Puller Service with connection string");
            builder.connectionString(connectionString);
        } else if (StringUtils.hasText(sasToken)) {
            logger.info("Creating Azure Blob Data Puller Service with SAS token");
            String token = sasToken.startsWith("?") ? sasToken.substring(1) : sasToken;
            builder.endpoint(String.format("https://%s.blob.core.windows.net", storageAccountName))
                    .credential(new AzureSasCredential(token));
        } else {
            throw new DataProcessorException("No Valid Azure Blob Storage authentication method found");
        }

        this.blobServiceClient = builder.buildClient();

        this.gson = new GsonBuilder()
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampSerializer())
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampDeserializer())
                .serializeNulls()
                .create();
    }

    public AzureBlobDataPullerService(BlobServiceClient blobServiceClient) {
        // for unit test
        this.blobServiceClient = blobServiceClient;
        this.gson = new GsonBuilder()
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampSerializer())
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampDeserializer())
                .serializeNulls()
                .create();
    }


    public JsonElement readJsonFromStorage(String fileName) {
        logger.debug("AzureBlobDataPullerService: Reading JSON from Azure Blob - fileName: {}", fileName);
        try {
            // Get container client
            BlobContainerClient containerClient = blobServiceClient.getBlobContainerClient(containerName);
            
            // Get blob client
            BlobClient blobClient = containerClient.getBlobClient(fileName);
            
            // Download blob content as binary data
            BinaryData binaryData = blobClient.downloadContent();
            String jsonData = binaryData.toString();

            // Parse JSON string to JsonElement
            logger.debug("AzureBlobDataPullerService: Successfully read {} bytes from Azure Blob", jsonData.length());
            return JsonParser.parseString(jsonData);
        } catch (Exception e) {
            logger.error("Azure Blob Read Error: {}, {}", fileName, e.getMessage());
        }
        return JsonParser.parseString("");
    }

    public String uploadDataToStorage(String folder1, String folder2, String folder3, String folder4, String fileName, String data) {
        String blobName = String.format("%s/%s/%s/%s/%s", folder1, folder2, folder3, folder4, fileName);
        logger.debug("AzureBlobDataPullerService: Uploading data to Azure Blob - blobName: {}, data size: {} bytes", blobName, data.length());

        try {
            // Get container client
            BlobContainerClient containerClient = blobServiceClient.getBlobContainerClient(containerName);
            
            // Get blob client
            BlobClient blobClient = containerClient.getBlobClient(blobName);
            
            // Upload data as binary data
            BinaryData binaryData = BinaryData.fromString(data);
            blobClient.upload(binaryData, true);

            logger.debug("AzureBlobDataPullerService: Successfully uploaded data to Azure Blob Storage: {}", blobName);
        } catch (Exception e) {
            logger.error("Azure Blob Write Error: {}, {}", blobName, e.getMessage());
        }
        return blobName;
    }
}
