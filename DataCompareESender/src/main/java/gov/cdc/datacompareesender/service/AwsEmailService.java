package gov.cdc.datacompareesender.service;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.simpleemail.AmazonSimpleEmailService;
import com.amazonaws.services.simpleemail.model.*;
import gov.cdc.datacompareesender.model.EmailEventModel;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.format.DateTimeFormatter;
import java.util.Date;

@Service
@Slf4j
public class AwsEmailService {
    private final AmazonSimpleEmailService sesClient;
    private final AmazonS3 s3Client;

    @Value("${aws.ses.source-email}")
    private String sourceEmail;

    @Value("${aws.s3.bucket-name}")
    private String bucketName;

    @Value("${aws.s3.url-expiration-hours}")
    private Integer urlExpirationHours;

    public AwsEmailService(AmazonSimpleEmailService sesClient, AmazonS3 s3Client) {
        this.sesClient = sesClient;
        this.s3Client = s3Client;
    }

    public void sendComparisonEmail(EmailEventModel emailEvent) {
        try {
            String presignedUrl = generatePresignedUrl(emailEvent.getReportPath());
            String emailBody = buildEmailContent(emailEvent, presignedUrl);

            SendEmailRequest request = new SendEmailRequest()
                    .withSource(sourceEmail)
                    .withDestination(new Destination().withToAddresses(emailEvent.getRecipients()))
                    .withMessage(new Message()
                            .withSubject(new Content().withData(
                                    String.format("Data Comparison Results - %s", emailEvent.getFileName())))
                            .withBody(new Body().withHtml(new Content().withData(emailBody))));

            sesClient.sendEmail(request);
            log.info("Successfully sent comparison email for file: {}", emailEvent.getFileName());
        } catch (Exception e) {
            log.error("Failed to send comparison email: {}", e.getMessage(), e);
            throw new RuntimeException("Email sending failed", e);
        }
    }

    private String generatePresignedUrl(String s3Path) {
        return s3Client.generatePresignedUrl(
                bucketName,
                s3Path,
                Date.from(Instant.now().plusSeconds(urlExpirationHours * 3600))
        ).toString();
    }

    private String buildEmailContent(EmailEventModel event, String reportUrl) {
        StringBuilder content = new StringBuilder();
        content.append("<html><body>");
        content.append("<h2>Data Comparison Results</h2>");
        content.append("<p>File: ").append(event.getFileName()).append("</p>");
        content.append("<p>Comparison Time: ").append(
                        event.getComparisonTime().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME))
                .append("</p>");

        if (!event.getDiscrepancies().isEmpty()) {
            content.append("<h3>Discrepancy Summary:</h3>");
            content.append("<ul>");
            event.getDiscrepancies().forEach((key, count) ->
                    content.append("<li>").append(key).append(": ").append(count).append("</li>"));
            content.append("</ul>");
        }

        content.append("<p><strong>Detailed Report: </strong><a href=\"")
                .append(reportUrl).append("\">Click here to view</a></p>");
        content.append("<p><i>Note: This link will expire in ")
                .append(urlExpirationHours).append(" hours</i></p>");
        content.append("</body></html>");

        return content.toString();
    }
}