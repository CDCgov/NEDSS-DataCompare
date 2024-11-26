package gov.cdc.datacompareesender.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import gov.cdc.datacompareesender.model.EmailEventModel;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class KafkaEmailConsumerService {
    private final EmailService emailService;
    private final ObjectMapper objectMapper;

    public KafkaEmailConsumerService(EmailService emailService, ObjectMapper objectMapper) {
        this.emailService = emailService;
        this.objectMapper = objectMapper;
    }

    @KafkaListener(topics = "${kafka.topic.data-compare-topic}")
    public void handleMessage(String message) {
        try {
            EmailEventModel emailEvent = objectMapper.readValue(message, EmailEventModel.class);
            log.info("Processing email request for file: {}", emailEvent.getFileName());
            emailService.sendComparisonEmail(emailEvent);
            log.info("Email sent successfully for file: {}", emailEvent.getFileName());
        } catch (Exception e) {
            log.error("Failed to process email request: {}", e.getMessage(), e);
        }
    }
}
