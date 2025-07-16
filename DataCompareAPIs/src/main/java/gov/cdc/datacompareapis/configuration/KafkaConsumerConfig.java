package gov.cdc.datacompareapis.configuration;

import com.fasterxml.jackson.databind.deser.std.StringDeserializer;
import gov.cdc.datacompareapis.property.KafkaPropertiesProvider;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaConsumerFactory;

import java.util.HashMap;
import java.util.Map;
@Slf4j
@EnableKafka
@Configuration
public class KafkaConsumerConfig {
    private final KafkaPropertiesProvider kafkaPropertiesProvider;

    public KafkaConsumerConfig(KafkaPropertiesProvider kafkaPropertiesProvider) {
        this.kafkaPropertiesProvider = kafkaPropertiesProvider;
    }


    @Bean
    public ConsumerFactory<String, String> consumerFactory() {
        final Map<String, Object> config = new HashMap<>();
        config.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, kafkaPropertiesProvider.getBootstrapServers());
        config.put(ConsumerConfig.GROUP_ID_CONFIG, kafkaPropertiesProvider.getGroupId());
        config.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        config.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        return new DefaultKafkaConsumerFactory<>(config);
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, String> kafkaListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory<String, String> factory =
                new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(consumerFactory());
        return  factory;
    }
}
