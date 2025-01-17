package gov.cdc.datacompareprocessor.service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;
import gov.cdc.datacompareprocessor.configuration.TimestampAdapter;
import gov.cdc.datacompareprocessor.exception.DataProcessorException;
import gov.cdc.datacompareprocessor.service.interfaces.IS3DataPullerService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.parameters.P;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.auth.credentials.AwsSessionCredentials;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.ResponseBytes;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.sts.StsClient;
import software.amazon.awssdk.services.sts.auth.StsAssumeRoleCredentialsProvider;

import java.sql.Timestamp;

@Service
public class S3DataPullerService implements IS3DataPullerService {
    private static Logger logger = LoggerFactory.getLogger(S3DataPullerService.class);

    @Value("${aws.s3.bucket-name}")
    private String bucketName;

    private final S3Client s3Client;

    private final Gson gson;

    @Autowired
    public S3DataPullerService(
            @Value("${aws.auth.static.key_id}") String keyId,
            @Value("${aws.auth.static.access_key}") String accessKey,
            @Value("${aws.auth.static.token}") String token,
            @Value("${aws.s3.region}") String region,
            @Value("${aws.auth.profile.profile_name}") String profile,
            @Value("${aws.auth.iam.enabled}") boolean iamEnable
    ) throws DataProcessorException
    {
        if (iamEnable) {
            logger.info("Creating S3 Data Service with IAM enabled");

            this.s3Client = S3Client.builder()
                    .region(Region.of(region))
                    .credentialsProvider(DefaultCredentialsProvider.create()) // Automatically retrieves IAM role credentials
                    .build();
        }
        else if (!keyId.isEmpty() && !accessKey.isEmpty() && !token.isEmpty()) {
            this.s3Client = S3Client.builder()
                    .region(Region.of(region))
                    .credentialsProvider(StaticCredentialsProvider.create(
                            AwsSessionCredentials.create(keyId, accessKey, token)))
                    .build();
        } else if (!profile.isEmpty()) {
            // Use profile credentials from ~/.aws/credentials
            this.s3Client = S3Client.builder()
                    .region(Region.of(region))
                    .credentialsProvider(ProfileCredentialsProvider.create(profile))
                    .build();
        }
        else {
            throw new DataProcessorException("No Valid AWS Profile or Credentials found");
        }
        this.gson = new GsonBuilder()
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampSerializer())
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampDeserializer())
                .serializeNulls()
                .create();
    }

    public S3DataPullerService(S3Client s3Client) {
        // for unit test
        this.s3Client = s3Client;
        this.gson = new GsonBuilder()
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampSerializer())
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampDeserializer())
                .serializeNulls()
                .create();
    }

    public JsonElement readJsonFromS3(String fileName)  {
        try {
            GetObjectRequest getObjectRequest = GetObjectRequest.builder()
                    .bucket(bucketName)
                    .key(fileName)
                    .build();

            // Get the JSON file as bytes
            ResponseBytes<GetObjectResponse> objectBytes = s3Client.getObjectAsBytes(getObjectRequest);
            String jsonData = objectBytes.asUtf8String();

            // Parse JSON string to JsonElement
            return JsonParser.parseString(jsonData);
        } catch (Exception e) {
            logger.info("S3 Read Error: {}, {}",fileName, e.getMessage());
        }
        return JsonParser.parseString("");
    }

    public String uploadDataToS3(String folder1, String folder2, String folder3, String folder4, String fileName, String data) {
        String s3Key = String.format("%s/%s/%s/%s/%s", folder1, folder2, folder3, folder4, fileName);

        try {
            // Build the S3 key by combining folder1, folder2, and fileName

            PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                    .bucket(bucketName)
                    .key(s3Key)
                    .build();

            // Upload the data as a String
            s3Client.putObject(putObjectRequest, RequestBody.fromString(data));

        } catch (Exception e) {
            logger.info("S3 Write Error: {}, {}", s3Key,e.getMessage());
        }
        return s3Key;

    }
}
