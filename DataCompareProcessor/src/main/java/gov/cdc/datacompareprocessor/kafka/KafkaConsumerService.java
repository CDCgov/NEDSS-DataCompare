package gov.cdc.datacompareprocessor.kafka;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import gov.cdc.datacompareprocessor.configuration.TimestampAdapter;
import gov.cdc.datacompareprocessor.service.interfaces.IDataCompareService;
import gov.cdc.datacompareprocessor.service.model.PullerEventModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;

@Service
public class KafkaConsumerService {
    private final Gson gson;
    private final IDataCompareService dataCompareService;

    private static final Logger logger = LoggerFactory.getLogger(KafkaConsumerService.class); //NOSONAR

    public KafkaConsumerService(IDataCompareService dataCompareService) {
        this.dataCompareService = dataCompareService;
        this.gson = new GsonBuilder()
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampSerializer())
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampDeserializer())
                .serializeNulls()
                .create();
    }

    @KafkaListener(
            topics = "${kafka.topic.data-compare-topic}"
    )
    public void handleMessage(String message){
        try {
            PullerEventModel data = gson.fromJson(message, PullerEventModel.class);
            logger.info("Compare is started for table {}" , data.getFileName());
            dataCompareService.processingData(data);
            logger.info("Compare is completed for table {}" , data.getFileName());
        } catch (Exception e) {
            logger.error("KafkaEdxLogConsumer.handleMessage: {}", e.getMessage());
        }

    }

}
