package gov.cdc.datacompareapis.property;

import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
@Getter
public class KafkaPropertiesProvider {
    @Value("${spring.kafka.group-id}")
    private String groupId = "";

    @Value("${spring.kafka.bootstrap-servers}")
    private String bootstrapServers = "";

    @Value("${kafka.topic.data-compare-topic}")
    String processorTopicName = "";
}
