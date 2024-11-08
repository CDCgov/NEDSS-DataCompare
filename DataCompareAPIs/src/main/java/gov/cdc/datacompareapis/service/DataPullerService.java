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
            var currentTime = getCurrentTimeStamp();
            DataCompareLog dataCompareLog = new DataCompareLog();
            dataCompareLog.setTableName(config.getTableName());
            dataCompareLog.setStartDateTime(currentTime);
            dataCompareLog.setFileLocation("CORRECT PATH GOES HERE");
            dataCompareLog.setStatus("IN_PROGRESS");
            dataCompareLog.setRunByUser("USER");

            Integer rdbCount = rdbJdbcTemplate.queryForObject(config.getRdbSqlCountQuery(), Integer.class);
            Integer rdbModernCount = rdbModernJdbcTemplate.queryForObject(config.getRdbModernSqlCountQuery(), Integer.class);
            boolean errorDuringPullingData = false;
            String stackTrace = null;
            if (rdbModernCount != null && rdbCount != null) {
                int totalRdbPages = (int) Math.ceil((double) rdbCount / pullLimit);
                int totalRdbModernPages = (int) Math.ceil((double) rdbModernCount / pullLimit);


                for (int i = 0; i < totalRdbPages; i++) {
                    try {
                        if (errorDuringPullingData) {
                            break;
                        }
                        int startRow = i * pullLimit + 1;
                        int endRow = (i + 1) * pullLimit;
                        String query = preparingPaginationQuery(config.getRdbSqlQuery(), startRow, endRow);
                        List<Map<String, Object>> returnData = executeQueryForData(query, config.getSourceDb());
                        String rawJsonData = gson.toJson(returnData);
                        s3DataService.persistToS3MultiPart(config.getSourceDb(),rawJsonData, config.getTableName(), currentTime, i);
                    } catch (Exception e) {
                        stackTrace = getStackTraceAsString(e);
                        logger.error(e.getMessage());
                        errorDuringPullingData = true;
                    }
                }

                for (int i = 0; i < totalRdbModernPages; i++) {
                    try {
                        if (errorDuringPullingData) {
                            break;
                        }
                        int startRow = i * pullLimit + 1;
                        int endRow = (i + 1) * pullLimit;
                        String query = preparingPaginationQuery(config.getRdbModernSqlQuery(), startRow, endRow);
                        List<Map<String, Object>> returnData = executeQueryForData(query, config.getTargetDb());
                        String rawJsonData = gson.toJson(returnData);
                        s3DataService.persistToS3MultiPart(config.getTargetDb(),rawJsonData, config.getTableName(), currentTime, i);
                    } catch (Exception e) {
                        stackTrace = getStackTraceAsString(e);
                        logger.error(e.getMessage());
                        errorDuringPullingData = true;
                    }
                }

                // PERSIST LOG HERE
                // Then Return the Id
                dataCompareLog.setStackTrace(stackTrace);
                var log = dataCompareLogRepository.save(dataCompareLog);

                // No Error then continue, otherwise stop at record the log
                if (!errorDuringPullingData) {
                    PullerEventModel pullerEventModel = new PullerEventModel();
                    pullerEventModel.setFileName(config.getTableName());
                    pullerEventModel.setFirstLayerRdbFolderName(config.getSourceDb());
                    pullerEventModel.setFirstLayerRdbModernFolderName(config.getTargetDb());
                    pullerEventModel.setSecondLayerFolderName(config.getTableName());
                    pullerEventModel.setKeyColumn(config.getKeyColumn());
                    pullerEventModel.setIgnoreColumns(config.getIgnoreColumns());
                    String formattedTimestamp = new SimpleDateFormat("yyyyMMddHHmmss").format(currentTime);
                    pullerEventModel.setThirdLayerFolderName(formattedTimestamp);
                    pullerEventModel.setRdbMaxIndex(totalRdbPages);
                    pullerEventModel.setRdbModernMaxIndex(totalRdbModernPages);
                    pullerEventModel.setLogId(log.getDcLogId());
                    String pullerEventString = gson.toJson(pullerEventModel);

                    kafkaProducerService.sendEventToProcessor(pullerEventString, processorTopicName);
                    logger.info("PULLER IS COMPLETED FOR {}", config.getTableName());
                }


            }


        }

        logger.info("PULLER IS COMPLETED FOR ALL TABLE");
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
