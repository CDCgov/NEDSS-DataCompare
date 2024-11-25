package gov.cdc.datacompareapis.service;

import gov.cdc.datacompareapis.exception.DataCompareException;
import gov.cdc.datacompareapis.service.interfaces.IS3DataService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.auth.credentials.AwsSessionCredentials;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import static gov.cdc.datacompareapis.constant.ConstantValue.LOG_SUCCESS;

@Service
public class S3DataService implements IS3DataService {
    private static Logger logger = LoggerFactory.getLogger(S3DataService.class);

    @Value("${aws.s3.bucket-name}")
    private String bucketName;

    private final S3Client s3Client;

    @Autowired
    public S3DataService(
            @Value("${aws.auth.static.key_id}") String keyId,
            @Value("${aws.auth.static.access_key}") String accessKey,
            @Value("${aws.auth.static.token}") String token,
            @Value("${aws.s3.region}") String region,
            @Value("${aws.auth.profile.profile_name}") String profile,
            @Value("${aws.auth.iam.enabled}") boolean iamEnable
    ) throws DataCompareException
    {
        if (iamEnable) {
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
        } else {
            throw new DataCompareException("No Valid AWS Profile or Credentials found");
        }
    }

    public S3DataService(S3Client s3Client) {
        // for unit test
        this.s3Client = s3Client;
    }


    /**
     * S3 location naming
     * DOMAIN/TABLE/TIMESTAMP/TABLE_INDEX
     * */
    public String persistToS3MultiPart(String domain, String records, String fileName, Timestamp persistingTimestamp, int index) {
        String log = LOG_SUCCESS;
        try {
            if (records.equalsIgnoreCase("[]") || records.isEmpty()) {
                throw new DataCompareException("No data to persist for table " + fileName);
            }
            String formattedTimestamp = new SimpleDateFormat("yyyyMMddHHmmss").format(persistingTimestamp);

            // Construct the file path: /filename/filename_timestamp.json
            String s3Key = String.format("%s/%s/%s/%s_%s.json", domain, fileName,formattedTimestamp, fileName, index);
            InputStream inputStream = new ByteArrayInputStream(records.getBytes(StandardCharsets.UTF_8));

            String uploadId = initiateMultipartUpload(s3Key);

            List<CompletedPart> completedParts = new ArrayList<>();
            byte[] buffer = new byte[5 * 1024 * 1024]; // 5MB buffer size
            int partNumber = 1;
            int bytesRead;

            // Split data into chunks and upload
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                // Create a new byte array that represents the valid portion of the buffer
                byte[] validBytes = new byte[bytesRead];
                System.arraycopy(buffer, 0, validBytes, 0, bytesRead);

                UploadPartRequest uploadPartRequest = UploadPartRequest.builder()
                        .bucket(bucketName)
                        .key(s3Key)
                        .uploadId(uploadId)
                        .partNumber(partNumber)
                        .build();

                // Use the validBytes array which contains only the read bytes
                CompletedPart completedPart = CompletedPart.builder()
                        .partNumber(partNumber)
                        .eTag(s3Client.uploadPart(uploadPartRequest,
                                software.amazon.awssdk.core.sync.RequestBody.fromBytes(validBytes)).eTag())
                        .build();

                completedParts.add(completedPart);
                partNumber++;
            }

            completeMultipartUpload(uploadId, s3Key, completedParts);
        }
        catch (Exception e)
        {
            logger.info(e.getMessage());
            log = e.getMessage();
        }
        return log;
    }


    private String initiateMultipartUpload(String fileName) {
        CreateMultipartUploadRequest multipartUploadRequest = CreateMultipartUploadRequest.builder()
                .bucket(bucketName)
                .key(fileName)
                .build();

        CreateMultipartUploadResponse response = s3Client.createMultipartUpload(multipartUploadRequest);
        return response.uploadId();
    }

    @SuppressWarnings("java:S6244")
    private void completeMultipartUpload(String uploadId, String fileName, List<CompletedPart> completedParts) {
        CompletedMultipartUpload completedMultipartUpload = CompletedMultipartUpload.builder()
                .parts(completedParts)
                .build();

        CompleteMultipartUploadRequest completeMultipartUploadRequest = CompleteMultipartUploadRequest.builder()
                .bucket(bucketName)
                .key(fileName)
                .uploadId(uploadId)
                .multipartUpload(completedMultipartUpload)
                .build();

        s3Client.completeMultipartUpload(completeMultipartUploadRequest);
    }
}
