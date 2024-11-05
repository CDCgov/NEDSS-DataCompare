package gov.cdc.datacompareapis.kafka;

import org.apache.kafka.clients.producer.ProducerRecord;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class KafkaProducerService {
    private final KafkaTemplate<String, String> kafkaTemplate;
    public KafkaProducerService( KafkaTemplate<String, String> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }


    public void sendEventToProcessor(String msg, String topic) {
        String uniqueID = String.valueOf(UUID.randomUUID());
        var prodRecord = new ProducerRecord<>(topic, uniqueID, msg);
        sendMessage(prodRecord);
    }
    private void sendMessage(ProducerRecord<String, String> prodRecord) {
        kafkaTemplate.send(prodRecord);
    }

}
