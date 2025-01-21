package gov.cdc.datacompareprocessor.service;

import gov.cdc.datacompareprocessor.exception.DataProcessorException;
import gov.cdc.datacompareprocessor.service.model.EmailEventModel;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.auth.credentials.AwsSessionCredentials;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.Bucket;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest;
import software.amazon.awssdk.services.ses.SesClient;
import software.amazon.awssdk.services.ses.model.*;

import java.time.Duration;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
public class EmailService {
    private final SesClient sesClient;
    private final S3Presigner s3Presigner;


    @Value("${aws.ses.source-email}")
    private String sourceEmail;

    @Value("${aws.ses.recipient-emails}")
    private String recipientEmails;

    @Value("${aws.s3.bucket-name}")
    private String bucketName;

    @Value("${aws.s3.url-expiration-hours}")
    private Integer urlExpirationHours;

    private static final Logger logger = LoggerFactory.getLogger(EmailService.class); //NOSONAR


    public EmailService(
            @Value("${aws.auth.static.key_id}") String keyId,
            @Value("${aws.auth.static.access_key}") String accessKey,
            @Value("${aws.auth.static.token}") String token,
            @Value("${aws.s3.region}") String region,
            @Value("${aws.auth.profile.profile_name}") String profile,
            @Value("${aws.auth.iam.enabled}") boolean iamEnable) throws DataProcessorException {

        if (iamEnable) {
            logger.info("AWS IAM Enabled");

            var credentials = DefaultCredentialsProvider.create();

            this.s3Presigner = S3Presigner.builder()
                    .region(Region.of(region))
                    .credentialsProvider(credentials) // Automatically retrieves IAM role credentials
                    .build();
            this.sesClient = SesClient.builder()
                    .region(Region.of(region))
                    .credentialsProvider(credentials) // Automatically retrieves IAM role credentials
                    .build();

        }
        else if (!keyId.isEmpty() && !accessKey.isEmpty() && !token.isEmpty()) {
            this.s3Presigner = S3Presigner.builder()
                    .region(Region.of(region))
                    .credentialsProvider(StaticCredentialsProvider.create(
                            AwsSessionCredentials.create(keyId, accessKey, token)))
                    .build();
            this.sesClient = SesClient.builder()
                    .region(Region.of(region))
                    .credentialsProvider(StaticCredentialsProvider.create(
                            AwsSessionCredentials.create(keyId, accessKey, token)))
                    .build();
        }
        else if (!profile.isEmpty()) {
            // Use profile credentials from ~/.aws/credentials
            this.s3Presigner = S3Presigner.builder()
                    .region(Region.of(region))
                    .credentialsProvider(ProfileCredentialsProvider.create(profile))
                    .build();
            this.sesClient = SesClient.builder()
                    .region(Region.of(region))
                    .credentialsProvider(ProfileCredentialsProvider.create(profile))
                    .build();
        }
        else {
            throw new DataProcessorException("No Valid AWS Profile or Credentials found");
        }
    }

    public void sendComparisonEmail(EmailEventModel emailEvent) {
        try {
            String presignedUrl = generatePresignedUrl(emailEvent.getDifferentFile());
            logger.info("PreSigned URL: {}", presignedUrl);

            String emailBody = buildEmailContent(emailEvent, presignedUrl);

            SendEmailRequest request = SendEmailRequest.builder()
                    .source(sourceEmail) // Sender's email
                    .destination(Destination.builder()
                            .toAddresses(getRecipientEmailList())
                            .build())
                    .message(Message.builder()
                            .subject(Content.builder()
                                    .data(String.format("Data Comparison Results - %s", emailEvent.getFileName()))
                                    .build())
                            .body(Body.builder()
                                    .html(Content.builder()
                                            .data(emailBody)
                                            .build())
                                    .build())
                            .build())
                    .build();
            sesClient.sendEmail(request);
            log.info("Successfully sent comparison email for file: {}", emailEvent.getFileName());
        } catch (Exception e) {
            log.error("Failed to send comparison email: {}", e.getMessage(), e);
            throw new RuntimeException("Email sending failed", e);
        }
    }

    private String generatePresignedUrl(String s3Path) {
        GetObjectRequest getObjectRequest = GetObjectRequest.builder()
                .bucket(bucketName)
                .key(s3Path)
                .build();
        GetObjectPresignRequest presignRequest = GetObjectPresignRequest.builder()
                .signatureDuration(Duration.ofHours(urlExpirationHours))
                .getObjectRequest(getObjectRequest)
                .build();
        return s3Presigner.presignGetObject(presignRequest).url().toString();
    }



    private String buildEmailContent(EmailEventModel event, String reportUrl) {
        StringBuilder content = new StringBuilder();
        content.append("<html><body>");
        content.append("<h2>Data Comparison Results</h2>");
        content.append("<p>S3 Bucket Name: ").append(event.getBucketName()).append("</p>");
        content.append("<p>Rdb record path: ").append(event.getRdbPath()).append("</p>");
        content.append("<p>Rdb Modern record path: ").append(event.getRdbModernPath()).append("</p>");
        content.append("<p>Compare Result file: ").append(event.getDifferentFile()).append("</p>");

        content.append("<p><strong>Detailed Report: </strong><a href=\"")
                .append(reportUrl).append("\">Click here to view</a></p>");
        content.append("<p><i>Note: This link will expire in ")
                .append(urlExpirationHours).append(" hours</i></p>");
        content.append("</body></html>");

        return content.toString();
    }

        private List<String> getRecipientEmailList() throws DataProcessorException {
        if (recipientEmails == null || recipientEmails.trim().isEmpty()) {
            log.error("No recipient emails configured");
            throw new DataProcessorException("No recipient emails configured");
        }

        List<String> emailList = Arrays.stream(recipientEmails.split(","))
                .map(String::trim)
                .filter(email -> !email.isEmpty())
                .collect(Collectors.toList());

        if (emailList.isEmpty()) {
            log.error("No valid recipient emails found after parsing");
            throw new DataProcessorException("No valid recipient emails found after parsing");
        }

        log.debug("Processed {} recipient email(s)", emailList.size());
        return emailList;
    }
}