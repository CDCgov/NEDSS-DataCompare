package gov.cdc.datacompareapis.service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import gov.cdc.datacompareapis.configuration.TimestampAdapter;
import gov.cdc.datacompareapis.exception.DataCompareException;
import gov.cdc.datacompareapis.kafka.KafkaProducerService;
import gov.cdc.datacompareapis.repository.rdb.DataCompareConfigRepository;
import gov.cdc.datacompareapis.repository.rdb.DataCompareLogRepository;
import gov.cdc.datacompareapis.repository.rdb.model.DataCompareConfig;
import gov.cdc.datacompareapis.repository.rdb.model.DataCompareLog;
import gov.cdc.datacompareapis.service.interfaces.IDataPullerService;
import gov.cdc.datacompareapis.service.interfaces.IS3DataService;
import gov.cdc.datacompareapis.service.model.PullerEventModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;

import static gov.cdc.datacompareapis.shared.StackTraceUtil.getStackTraceAsString;
import static gov.cdc.datacompareapis.shared.TimestampHandler.getCurrentTimeStamp;

@Service
public class DataPullerService implements IDataPullerService {
    private static Logger logger = LoggerFactory.getLogger(DataPullerService.class);

    private final DataCompareConfigRepository dataCompareConfigRepository;
    private final DataCompareLogRepository dataCompareLogRepository;
    private final KafkaProducerService kafkaProducerService;
    private final Gson gson;
    private final JdbcTemplate rdbJdbcTemplate;
    private final JdbcTemplate rdbModernJdbcTemplate;
    private final IS3DataService s3DataService;

    @Value("${kafka.topic.data-compare-topic}")
    String processorTopicName = "";

    public DataPullerService(DataCompareConfigRepository dataCompareConfigRepository,
                             DataCompareLogRepository dataCompareLogRepository,
                             KafkaProducerService kafkaProducerService, @Qualifier("rdbJdbcTemplate") JdbcTemplate rdbJdbcTemplate,
                             @Qualifier("rdbModernJdbcTemplate") JdbcTemplate rdbModernJdbcTemplate,
                             IS3DataService s3DataService) {
        this.dataCompareConfigRepository = dataCompareConfigRepository;
        this.dataCompareLogRepository = dataCompareLogRepository;
        this.kafkaProducerService = kafkaProducerService;
        this.rdbJdbcTemplate = rdbJdbcTemplate;
        this.rdbModernJdbcTemplate = rdbModernJdbcTemplate;
        this.s3DataService = s3DataService;
        this.gson = new GsonBuilder()
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampSerializer())
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampDeserializer())
                .serializeNulls()
                .create();
    }

    @Async("defaultAsyncExecutor")
    public void pullingData(int pullLimit)   {
        List<DataCompareConfig>  configs = getDataConfig();
        for(DataCompareConfig config : configs) {
            Integer rdbCount = rdbJdbcTemplate.queryForObject(config.getRdbSqlCountQuery(), Integer.class);
            Integer rdbModernCount = rdbModernJdbcTemplate.queryForObject(config.getRdbModernSqlCountQuery(), Integer.class);
            if (rdbModernCount != null && rdbCount != null) {
                int totalRdbPages = (int) Math.ceil((double) rdbCount / pullLimit);
                int totalRdbModernPages = (int) Math.ceil((double) rdbModernCount / pullLimit);


                var currentTime = getCurrentTimeStamp();
                for (int i = 0; i < totalRdbPages; i++) {
                    var transactionStartTime = getCurrentTimeStamp();
                    try {
                        int startRow = i * pullLimit + 1;
                        int endRow = (i + 1) * pullLimit;
                        String query = preparingPaginationQuery(config.getRdbSqlQuery(), startRow, endRow);
                        List<Map<String, Object>> returnData = executeQueryForData(query, config.getSourceDb());
                        var transactionEndTime = getCurrentTimeStamp();
                        String rawJsonData = gson.toJson(returnData);
                        s3DataService.persistToS3MultiPart(config.getSourceDb(),rawJsonData, config.getTableName(), currentTime, i);
                    } catch (Exception e) {
                        var transactionEndTime = getCurrentTimeStamp();
                        var stackTrace = getStackTraceAsString(e);
                        logger.error(e.getMessage());
                    }
                }

                for (int i = 0; i < totalRdbModernPages; i++) {
                    var transactionStartTime = getCurrentTimeStamp();
                    try {
                        int startRow = i * pullLimit + 1;
                        int endRow = (i + 1) * pullLimit;
                        String query = preparingPaginationQuery(config.getRdbModernSqlQuery(), startRow, endRow);
                        List<Map<String, Object>> returnData = executeQueryForData(query, config.getTargetDb());
                        var transactionEndTime = getCurrentTimeStamp();
                        String rawJsonData = gson.toJson(returnData);
                        s3DataService.persistToS3MultiPart(config.getTargetDb(),rawJsonData, config.getTableName(), currentTime, i);
                    } catch (Exception e) {
                        var transactionEndTime = getCurrentTimeStamp();
                        var stackTrace = getStackTraceAsString(e);
                        logger.error(e.getMessage());
                    }
                }

                PullerEventModel pullerEventModel = new PullerEventModel();
                pullerEventModel.setFileName(config.getTableName());
                pullerEventModel.setFirstLayerRdbFolderName(config.getSourceDb());
                pullerEventModel.setFirstLayerRdbModernFolderName(config.getTargetDb());
                pullerEventModel.setSecondLayerFolderName(config.getTableName());
                String formattedTimestamp = new SimpleDateFormat("yyyyMMddHHmmss").format(currentTime);
                pullerEventModel.setThirdLayerFolderName(formattedTimestamp);
                pullerEventModel.setRdbMaxIndex(totalRdbPages);
                pullerEventModel.setRdbModernMaxIndex(totalRdbModernPages);
                String pullerEventString = gson.toJson(pullerEventModel);

                kafkaProducerService.sendEventToProcessor(pullerEventString, processorTopicName);
                logger.info("PULLER IS COMPLETED FOR {}", config.getTableName());
            }


        }

        logger.info("PULLER IS COMPLETED FOR ALL TABLE");
    }

    protected DataCompareLog buildingLog(String tableName,
                                         String dbName,
                                         Timestamp startDateTime,
                                         Timestamp endDateTime,
                                         String executedQuery
                                         ) {
        DataCompareLog dcl = new DataCompareLog();
        dcl.setTableName(tableName);
        dcl.setDatabase(dbName);
        dcl.setStartDateTime(startDateTime);
        dcl.setEndDateTime(endDateTime);
        dcl.setExecutedQuery(executedQuery);
        return  dcl;
    }



    protected String preparingPaginationQuery(String query, Integer startRow, Integer endRow) {
        return query.replaceAll(":startRow", startRow.toString()).replaceAll(":endRow", endRow.toString());
    }

    protected List<Map<String, Object>> executeQueryForData(String query, String sourceDb) throws DataCompareException {
        if (sourceDb.equalsIgnoreCase("RDB")) {
            return rdbJdbcTemplate.queryForList(query);
        } else if (sourceDb.equalsIgnoreCase("RDB_MODERN")) {
            return rdbModernJdbcTemplate.queryForList(query);
        } else {
            throw new DataCompareException("DB IS NOT SUPPORTED: " + sourceDb);
        }
    }


    private List<DataCompareConfig> getDataConfig() {
        return dataCompareConfigRepository.findAll();
    }


}
