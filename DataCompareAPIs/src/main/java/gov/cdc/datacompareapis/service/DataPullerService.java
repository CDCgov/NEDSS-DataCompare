package gov.cdc.datacompareapis.service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import gov.cdc.datacompareapis.configuration.TimestampAdapter;
import gov.cdc.datacompareapis.exception.DataCompareException;
import gov.cdc.datacompareapis.kafka.KafkaProducerService;
import gov.cdc.datacompareapis.repository.dataCompare.DataCompareConfigRepository;
import gov.cdc.datacompareapis.repository.dataCompare.DataCompareLogRepository;
import gov.cdc.datacompareapis.repository.dataCompare.model.DataCompareConfig;
import gov.cdc.datacompareapis.repository.dataCompare.model.DataCompareLog;
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
    public void pullingData(int pullLimit, boolean runNowMode, boolean autoApply)   {
        List<DataCompareConfig>  configs = getDataConfig();
        if (autoApply) {
            pullDataAutomaticApplyingCondition(pullLimit, configs);
        }
        else {
            if (runNowMode) {
                pullDataRunNow(pullLimit, configs);
            }
            else {
                pullDataAllTable(pullLimit, configs);
            }

        }

        logger.info("PULLER IS COMPLETED FOR ALL TABLE");
    }

    protected void pullDataAutomaticApplyingCondition (int pullLimit, List<DataCompareConfig>  configs) {
        boolean runNowOpt = configs.stream().anyMatch(DataCompareConfig::getRunNow);
        if (runNowOpt) {
            pullDataRunNow(pullLimit, configs);
        }
        else {
            pullDataAllTable(pullLimit, configs);
        }

    }



    protected void pullDataAllTable(int pullLimit, List<DataCompareConfig>  configs) {
        for(DataCompareConfig config : configs) {
            if (config.getCompare()) {
                pullDataLogic(pullLimit, config);
            }
        }
    }

    protected void pullDataRunNow(int pullLimit, List<DataCompareConfig>  configs) {
        for(DataCompareConfig config : configs) {
            if (config.getCompare() && config.getRunNow()) {
                pullDataLogic(pullLimit, config);
            }
        }
    }

    protected DataCompareLog dataCompareDefaultLogBuilder(DataCompareConfig config, Timestamp currentTime, String status,
                                                          String dbSource) {
        DataCompareLog dataCompareLog = new DataCompareLog();
        dataCompareLog.setConfigId(config.getConfigId());
        dataCompareLog.setTableName(dbSource + "." + config.getTableName());
        dataCompareLog.setStartDateTime(currentTime);
        dataCompareLog.setFileLocation("S3");
        dataCompareLog.setStatus(status);
        dataCompareLog.setRunByUser("0");
        return dataCompareLog;

    }

    protected void pullDataLogic(int pullLimit, DataCompareConfig config ) {
        var currentTime = getCurrentTimeStamp();
        DataCompareLog dataCompareLogRdb =dataCompareDefaultLogBuilder(config, currentTime, "Inprogress", "RDB");
        DataCompareLog dataCompareLogRdbModern =dataCompareDefaultLogBuilder(config, currentTime, "Inprogress", "RDB_MODERN");

        Integer rdbCount = rdbJdbcTemplate.queryForObject(config.getQueryCount(), Integer.class);
        Integer rdbModernCount = 0;
        if (config.getQueryRtrCount() != null && !config.getQueryRtrCount().isEmpty())
        {
            rdbModernCount = rdbModernJdbcTemplate.queryForObject(config.getQueryRtrCount(), Integer.class);
        }
        else
        {
            rdbModernCount = rdbModernJdbcTemplate.queryForObject(config.getQueryCount(), Integer.class);
        }
        boolean errorDuringPullingDataRdb = false;
        String stackTraceRdb = null;
        boolean errorDuringPullingDataRdbModern = false;
        String stackTraceRdbModern = null;
        if (rdbModernCount != null && rdbCount != null) {
            int totalRdbPages = (int) Math.ceil((double) rdbCount / pullLimit);
            int totalRdbModernPages = (int) Math.ceil((double) rdbModernCount / pullLimit);


            for (int i = 0; i < totalRdbPages; i++) {
                try {
                    if (errorDuringPullingDataRdb) {
                        break;
                    }
                    int startRow = i * pullLimit + 1;
                    int endRow = (i + 1) * pullLimit;
                    String query = preparingPaginationQuery(config.getQuery(), startRow, endRow);
                    List<Map<String, Object>> returnData = executeQueryForData(query, config.getSourceDb());
                    String rawJsonData = gson.toJson(returnData);
                    s3DataService.persistToS3MultiPart(config.getSourceDb(),rawJsonData, config.getTableName(), currentTime, i);
                } catch (Exception e) {
                    stackTraceRdb = getStackTraceAsString(e);
                    e.printStackTrace();
                    logger.error(e.getMessage());
                    errorDuringPullingDataRdb = true;
                }
            }

            for (int i = 0; i < totalRdbModernPages; i++) {
                try {
                    if (errorDuringPullingDataRdbModern) {
                        break;
                    }
                    int startRow = i * pullLimit + 1;
                    int endRow = (i + 1) * pullLimit;
                    String query = "";
                    if (config.getQueryRtr() != null && !config.getQueryRtr().isEmpty()) {
                        query = preparingPaginationQuery(config.getQueryRtr(), startRow, endRow);
                    }
                    else {
                        query = preparingPaginationQuery(config.getQuery(), startRow, endRow);
                    }
                    List<Map<String, Object>> returnData = executeQueryForData(query, config.getTargetDb());
                    String rawJsonData = gson.toJson(returnData);
                    s3DataService.persistToS3MultiPart(config.getTargetDb(),rawJsonData, config.getTableName(), currentTime, i);
                } catch (Exception e) {
                    e.printStackTrace();
                    stackTraceRdbModern = getStackTraceAsString(e);
                    logger.error(e.getMessage());
                    errorDuringPullingDataRdbModern = true;
                }
            }

            // PERSIST LOG HERE
            // Then Return the Id
            dataCompareLogRdb.setStatusDesc(stackTraceRdb);
            var logRdb = dataCompareLogRepository.save(dataCompareLogRdb);

            dataCompareLogRdbModern.setStatusDesc(stackTraceRdbModern);
            var logRdbModern = dataCompareLogRepository.save(dataCompareLogRdbModern);


            // No Error then continue, otherwise stop at record the log
            if (!errorDuringPullingDataRdb || !errorDuringPullingDataRdbModern) {
                PullerEventModel pullerEventModel = new PullerEventModel();
                pullerEventModel.setFileName(config.getTableName());
                pullerEventModel.setFirstLayerRdbFolderName(config.getSourceDb());
                pullerEventModel.setFirstLayerRdbModernFolderName(config.getTargetDb());
                pullerEventModel.setSecondLayerFolderName(config.getTableName());
                pullerEventModel.setKeyColumn(config.getKeyColumns());
                pullerEventModel.setIgnoreColumns(config.getIgnoreColumns());
                String formattedTimestamp = new SimpleDateFormat("yyyyMMddHHmmss").format(currentTime);
                pullerEventModel.setThirdLayerFolderName(formattedTimestamp);
                pullerEventModel.setRdbMaxIndex(totalRdbPages);
                pullerEventModel.setRdbModernMaxIndex(totalRdbModernPages);
                pullerEventModel.setLogIdRdb(logRdb.getDcLogId());
                pullerEventModel.setLogIdRdbModern(logRdbModern.getDcLogId());
                String pullerEventString = gson.toJson(pullerEventModel);

                kafkaProducerService.sendEventToProcessor(pullerEventString, processorTopicName);
                logger.info("PULLER IS COMPLETED FOR {}", config.getTableName());
            }
            else {
                logRdb.setStatus("Error");
                logRdbModern.setStatus("Error");
                dataCompareLogRepository.save(logRdb);
                dataCompareLogRepository.save(logRdbModern);
            }


        }
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
