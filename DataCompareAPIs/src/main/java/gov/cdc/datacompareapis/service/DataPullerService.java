package gov.cdc.datacompareapis.service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import gov.cdc.datacompareapis.configuration.TimestampAdapter;
import gov.cdc.datacompareapis.exception.DataCompareException;
import gov.cdc.datacompareapis.kafka.KafkaProducerService;
import gov.cdc.datacompareapis.repository.dataCompare.DataCompareBatchRepository;
import gov.cdc.datacompareapis.repository.dataCompare.DataCompareConfigRepository;
import gov.cdc.datacompareapis.repository.dataCompare.DataCompareLogRepository;
import gov.cdc.datacompareapis.repository.dataCompare.model.DataCompareBatch;
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
import java.util.UUID;

import static gov.cdc.datacompareapis.shared.StackTraceUtil.getStackTraceAsString;
import static gov.cdc.datacompareapis.shared.TimestampHandler.getCurrentTimeStamp;

@Service
public class DataPullerService implements IDataPullerService {
    private static Logger logger = LoggerFactory.getLogger(DataPullerService.class);
    private final DataCompareBatchRepository dataCompareBatchRepository;
    private final DataCompareConfigRepository dataCompareConfigRepository;
    private final DataCompareLogRepository dataCompareLogRepository;
    private final KafkaProducerService kafkaProducerService;
    private final Gson gson;
    private final JdbcTemplate rdbJdbcTemplate;
    private final JdbcTemplate rdbModernJdbcTemplate;
    private final JdbcTemplate odseJdbcTemplate;
    private final IS3DataService s3DataService;
    private long batchId ;
    @Value("${kafka.topic.data-compare-topic}")
    String processorTopicName = "";

    public DataPullerService(DataCompareConfigRepository dataCompareConfigRepository,
                             DataCompareLogRepository dataCompareLogRepository,
                             KafkaProducerService kafkaProducerService, @Qualifier("rdbJdbcTemplate") JdbcTemplate rdbJdbcTemplate,
                             @Qualifier("rdbModernJdbcTemplate") JdbcTemplate rdbModernJdbcTemplate,
                             @Qualifier("odseJdbcTemplate") JdbcTemplate odseJdbcTemplate,
                             IS3DataService s3DataService , DataCompareBatchRepository dataCompareBatchRepository) {
        this.dataCompareConfigRepository = dataCompareConfigRepository;
        this.dataCompareLogRepository = dataCompareLogRepository;
        this.kafkaProducerService = kafkaProducerService;
        this.rdbJdbcTemplate = rdbJdbcTemplate;
        this.rdbModernJdbcTemplate = rdbModernJdbcTemplate;
        this.odseJdbcTemplate = odseJdbcTemplate;
        this.s3DataService = s3DataService;
        this.dataCompareBatchRepository = dataCompareBatchRepository;
        this.gson = new GsonBuilder()
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampSerializer())
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampDeserializer())
                .serializeNulls()
                .create();
        this.batchId=0;
    }


    @Async("defaultAsyncExecutor")
    public void pullingData(int pullLimit, boolean runNowMode)   {
        List<DataCompareConfig>  configs = getDataConfig();
        batchId = createBatchId();
        if (runNowMode) {
            pullDataRunNow(pullLimit, configs);
        }
        else {
            pullDataAllTable(pullLimit, configs);
        }

        logger.info("PULLER IS COMPLETED FOR ALL TABLE");
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
        dataCompareLog.setBatchId(batchId);
        return dataCompareLog;

    }


    protected void pullDataLogic(int pullLimit, DataCompareConfig config ) {
        var currentTime = getCurrentTimeStamp();
        DataCompareLog dataCompareLogSource = dataCompareDefaultLogBuilder(config, currentTime, "Inprogress", config.getSourceDb());
        DataCompareLog dataCompareLogTarget = dataCompareDefaultLogBuilder(config, currentTime, "Inprogress", config.getTargetDb());

        Integer sourceCount;
        Integer targetCount;
        boolean errorDuringPullingDataSource = false;
        String stackTraceSource = null;
        boolean errorDuringPullingDataTarget = false;
        String stackTraceTarget = null;

        // ODSE-to-ODSE logic for different tables
        if ("NBS_ODSE".equalsIgnoreCase(config.getSourceDb()) && "NBS_ODSE".equalsIgnoreCase(config.getTargetDb())) {
            sourceCount = odseJdbcTemplate.queryForObject(config.getQueryCount(), Integer.class);
            targetCount = odseJdbcTemplate.queryForObject(config.getTargetQueryCount(), Integer.class);
            if (sourceCount != null && targetCount != null) {
                int totalSourcePages = (int) Math.ceil((double) sourceCount / pullLimit);
                int totalTargetPages = (int) Math.ceil((double) targetCount / pullLimit);

                for (int i = 0; i < totalSourcePages; i++) {
                    try {
                        if (errorDuringPullingDataSource) break;
                        int startRow = i * pullLimit + 1;
                        int endRow = (i + 1) * pullLimit;
                        String query = preparingPaginationQuery(config.getQuery(), startRow, endRow);
                        List<Map<String, Object>> returnData = odseJdbcTemplate.queryForList(query);
                        String rawJsonData = gson.toJson(returnData);
                        s3DataService.persistToS3MultiPart(config.getSourceDb(), rawJsonData, config.getTableName(), currentTime, i);
                    } catch (Exception e) {
                        stackTraceSource = getStackTraceAsString(e);
                        logger.error(e.getMessage());
                        errorDuringPullingDataSource = true;
                    }
                }
                for (int i = 0; i < totalTargetPages; i++) {
                    try {
                        if (errorDuringPullingDataTarget) break;
                        int startRow = i * pullLimit + 1;
                        int endRow = (i + 1) * pullLimit;
                        String query = preparingPaginationQuery(config.getTargetQuery(), startRow, endRow);
                        List<Map<String, Object>> returnData = executeQueryForData(query, config.getSourceDb());
                        String rawJsonData = gson.toJson(returnData);
                        s3DataService.persistToS3MultiPart(config.getTargetDb(), rawJsonData, config.getTargetTableName(), currentTime, i);
                    } catch (Exception e) {
                        stackTraceTarget = getStackTraceAsString(e);
                        logger.error(e.getMessage());
                        errorDuringPullingDataTarget = true;
                    }
                }
                dataCompareLogSource.setStatusDesc(stackTraceSource);
                var logSource = dataCompareLogRepository.save(dataCompareLogSource);
                dataCompareLogTarget.setStatusDesc(stackTraceTarget);
                var logTarget = dataCompareLogRepository.save(dataCompareLogTarget);
                if (!errorDuringPullingDataSource && !errorDuringPullingDataTarget) {
                    PullerEventModel pullerEventModel = new PullerEventModel();
                    pullerEventModel.setSourceFileName(config.getTableName());
                    pullerEventModel.setTargetFileName(config.getTargetTableName());
                    pullerEventModel.setFirstLayerOdseSourceFolderName(config.getSourceDb());
                    pullerEventModel.setFirstLayerOdseTargetFolderName(config.getTargetDb());
                    pullerEventModel.setSecondLayerFolderName(config.getTableName());
                    pullerEventModel.setKeyColumn(config.getKeyColumns());
                    pullerEventModel.setIgnoreColumns(config.getIgnoreColumns());
                    String formattedTimestamp = new SimpleDateFormat("yyyyMMddHHmmss").format(currentTime);
                    pullerEventModel.setThirdLayerFolderName(formattedTimestamp);
                    pullerEventModel.setOdseSourceMaxIndex(totalSourcePages);
                    pullerEventModel.setOdseTargetMaxIndex(totalTargetPages);
                    pullerEventModel.setLogIdOdseSource(logSource.getDcLogId());
                    pullerEventModel.setLogIdOdseTarget(logTarget.getDcLogId());
                    String pullerEventString = gson.toJson(pullerEventModel);
                    kafkaProducerService.sendEventToProcessor(pullerEventString, processorTopicName);
                    logger.info("PULLER IS COMPLETED FOR {} and {}", config.getTableName(), config.getTargetTableName());
//                    config.setRunNow(false);
                    dataCompareConfigRepository.save(config);
                } else {
                    logSource.setStatus("Error");
                    logTarget.setStatus("Error");
                    dataCompareLogRepository.save(logSource);
                    dataCompareLogRepository.save(logTarget);
                }
            }
        }

        if("RDB".equalsIgnoreCase(config.getSourceDb()) && "RDB_MODERN".equalsIgnoreCase(config.getTargetDb())) {
            sourceCount = rdbJdbcTemplate.queryForObject(config.getQueryCount(), Integer.class);
            targetCount = rdbModernJdbcTemplate.queryForObject(config.getQueryCount(), Integer.class);
            
            // RDB-to-RDB_MODERN logic
            if (sourceCount != null && targetCount != null) {
                int totalRdbPages = (int) Math.ceil((double) sourceCount / pullLimit);
                int totalRdbModernPages = (int) Math.ceil((double) targetCount / pullLimit);


                for (int i = 0; i < totalRdbPages; i++) {
                    try {
                        if (errorDuringPullingDataSource) {
                            break;
                        }
                        int startRow = i * pullLimit + 1;
                        int endRow = (i + 1) * pullLimit;
                        String query = preparingPaginationQuery(config.getQuery(), startRow, endRow);
                        List<Map<String, Object>> returnData = executeQueryForData(query, config.getSourceDb());
                        String rawJsonData = gson.toJson(returnData);
                        s3DataService.persistToS3MultiPart(config.getSourceDb(),rawJsonData, config.getTableName(), currentTime, i);
                    } catch (Exception e) {
                        stackTraceSource = getStackTraceAsString(e);
                        logger.error(e.getMessage());
                        errorDuringPullingDataSource = true;
                    }
                }

                for (int i = 0; i < totalRdbModernPages; i++) {
                    try {
                        if (errorDuringPullingDataTarget) {
                            break;
                        }
                        int startRow = i * pullLimit + 1;
                        int endRow = (i + 1) * pullLimit;
                        String query = preparingPaginationQuery(config.getQuery(), startRow, endRow);
                        List<Map<String, Object>> returnData = executeQueryForData(query, config.getTargetDb());
                        String rawJsonData = gson.toJson(returnData);
                        s3DataService.persistToS3MultiPart(config.getTargetDb(),rawJsonData, config.getTableName(), currentTime, i);
                    } catch (Exception e) {
                        stackTraceTarget = getStackTraceAsString(e);
                        logger.error(e.getMessage());
                        errorDuringPullingDataTarget = true;
                    }
                }

                // PERSIST LOG HERE
                // Then Return the Id
                dataCompareLogSource.setStatusDesc(stackTraceSource);
                var logSource = dataCompareLogRepository.save(dataCompareLogSource);

                dataCompareLogTarget.setStatusDesc(stackTraceTarget);
                var logTarget = dataCompareLogRepository.save(dataCompareLogTarget);


                // No Error then continue, otherwise stop at record the log
                if (!errorDuringPullingDataSource || !errorDuringPullingDataTarget) {
                    PullerEventModel pullerEventModel = new PullerEventModel();
                    pullerEventModel.setSourceFileName(config.getTableName());
                    pullerEventModel.setFirstLayerRdbFolderName(config.getSourceDb());
                    pullerEventModel.setFirstLayerRdbModernFolderName(config.getTargetDb());
                    pullerEventModel.setSecondLayerFolderName(config.getTableName());
                    pullerEventModel.setKeyColumn(config.getKeyColumns());
                    pullerEventModel.setIgnoreColumns(config.getIgnoreColumns());
                    String formattedTimestamp = new SimpleDateFormat("yyyyMMddHHmmss").format(currentTime);
                    pullerEventModel.setThirdLayerFolderName(formattedTimestamp);
                    pullerEventModel.setRdbMaxIndex(totalRdbPages);
                    pullerEventModel.setRdbModernMaxIndex(totalRdbModernPages);
                    pullerEventModel.setLogIdRdb(logSource.getDcLogId());
                    pullerEventModel.setLogIdRdbModern(logTarget.getDcLogId());
                    String pullerEventString = gson.toJson(pullerEventModel);

                    kafkaProducerService.sendEventToProcessor(pullerEventString, processorTopicName);
                    logger.info("PULLER IS COMPLETED FOR {}", config.getTableName());

                    // Set run_now to false and save to database
//                    config.setRunNow(false);
                    dataCompareConfigRepository.save(config);
                }
                else {
                    logSource.setStatus("Error");
                    logTarget.setStatus("Error");
                    dataCompareLogRepository.save(logSource);
                    dataCompareLogRepository.save(logTarget);
                }
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
        } else if (sourceDb.equalsIgnoreCase("NBS_ODSE")) {
            return odseJdbcTemplate.queryForList(query);
        } else {
            throw new DataCompareException("DB IS NOT SUPPORTED: " + sourceDb);
        }
    }


    private List<DataCompareConfig> getDataConfig() {
        return dataCompareConfigRepository.findAll();
    }



    private long createBatchId(){
        var currentTime = getCurrentTimeStamp();
        DataCompareBatch dataCompareBatch = new DataCompareBatch();
        String batchName = UUID.randomUUID().toString();
        dataCompareBatch.setBatchName(batchName);
        dataCompareBatch.setCreatedDatetime(currentTime);
        dataCompareBatch.setCreatedBy("0");
        var batch = dataCompareBatchRepository.save(dataCompareBatch);
        return  batch.getBatchId();
    }

}
