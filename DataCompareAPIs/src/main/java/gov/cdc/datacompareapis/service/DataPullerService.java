package gov.cdc.datacompareapis.service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import gov.cdc.datacompareapis.configuration.TimestampAdapter;
import gov.cdc.datacompareapis.exception.DataCompareException;
import gov.cdc.datacompareapis.kafka.KafkaProducerService;
import gov.cdc.datacompareapis.property.KafkaPropertiesProvider;
import gov.cdc.datacompareapis.repository.dataCompare.DataCompareBatchRepository;
import gov.cdc.datacompareapis.repository.dataCompare.DataCompareConfigRepository;
import gov.cdc.datacompareapis.repository.dataCompare.DataCompareLogRepository;
import gov.cdc.datacompareapis.repository.dataCompare.model.DataCompareBatch;
import gov.cdc.datacompareapis.repository.dataCompare.model.DataCompareConfig;
import gov.cdc.datacompareapis.repository.dataCompare.model.DataCompareLog;
import gov.cdc.datacompareapis.service.interfaces.IDataPullerService;
import gov.cdc.datacompareapis.service.interfaces.IStorageDataService;
import gov.cdc.datacompareapis.service.model.PullerEventModel;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

import static gov.cdc.datacompareapis.shared.StackTraceUtil.getStackTraceAsString;
import static gov.cdc.datacompareapis.shared.TimestampHandler.getCurrentTimeStamp;
import static gov.cdc.datacompareapis.constant.ConstantValue.LOG_SUCCESS;

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
    private final IStorageDataService storageDataService;
    private final KafkaPropertiesProvider kafkaPropertiesProvider;
    private final Executor chunkTaskExecutor;
    private long batchId;
    private volatile boolean errorDuringPullingDataSource = false;


    public DataPullerService(DataCompareConfigRepository dataCompareConfigRepository,
                             DataCompareLogRepository dataCompareLogRepository,
                             KafkaProducerService kafkaProducerService,
                             @Qualifier("rdbJdbcTemplate") JdbcTemplate rdbJdbcTemplate,
                             @Qualifier("rdbModernJdbcTemplate") JdbcTemplate rdbModernJdbcTemplate,
                             KafkaPropertiesProvider kafkaPropertiesProvider,
                             @Qualifier("odseJdbcTemplate") JdbcTemplate odseJdbcTemplate,
                           //  @Qualifier("awsS3") IStorageDataService s3DataService ,
                             DataCompareBatchRepository dataCompareBatchRepository,
                             @Qualifier("chunkTaskExecutor") Executor chunkTaskExecutor) {
        this.dataCompareConfigRepository = dataCompareConfigRepository;
        this.dataCompareLogRepository = dataCompareLogRepository;
        this.kafkaProducerService = kafkaProducerService;
        this.rdbJdbcTemplate = rdbJdbcTemplate;
        this.rdbModernJdbcTemplate = rdbModernJdbcTemplate;
        this.odseJdbcTemplate = odseJdbcTemplate;
        this.storageDataService = storageDataService;
        this.dataCompareBatchRepository = dataCompareBatchRepository;
        this.kafkaPropertiesProvider = kafkaPropertiesProvider;
        this.chunkTaskExecutor = chunkTaskExecutor;
        this.gson = new GsonBuilder()
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampSerializer())
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampDeserializer())
                .serializeNulls()
                .create();
        this.batchId=0;
    }


    @Async("pullerTaskExecutor")
    public void pullingData(int pullLimit, boolean runNowMode)   {
        long startTime = System.currentTimeMillis();
        logger.info("Starting data pulling - pullLimit: {}, runNowMode: {}", pullLimit, runNowMode);
        
        errorDuringPullingDataSource = false;
        
        List<DataCompareConfig>  configs = getDataConfig();
        batchId = createBatchId();
        if (runNowMode) {
            pullDataRunNow(pullLimit, configs);
        }
        else {
            pullDataAllTable(pullLimit, configs);
        }

        long endTime = System.currentTimeMillis();
        long totalDuration = endTime - startTime;
        logger.info("PULLER IS COMPLETED FOR ALL TABLE in {}ms", totalDuration);
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

        if("RDB".equalsIgnoreCase(config.getSourceDb()) && "RDB_MODERN".equalsIgnoreCase(config.getTargetDb())) {
            sourceCount = rdbJdbcTemplate.queryForObject(config.getQueryCount(), Integer.class);
            targetCount = rdbModernJdbcTemplate.queryForObject(config.getQueryCount(), Integer.class);
            
            // RDB-to-RDB_MODERN logic
            if (sourceCount != null && targetCount != null) {
                int totalRdbPages = (int) Math.ceil((double) sourceCount / pullLimit);
                int totalRdbModernPages = (int) Math.ceil((double) targetCount / pullLimit);

                long tableStartTime = System.currentTimeMillis();
                logger.info("Starting parallel data pulling for table: {} - Source pages: {}, Target pages: {}", 
                           config.getTableName(), totalRdbPages, totalRdbModernPages);

                AtomicReference<String> sourceStackTrace = new AtomicReference<>();
                AtomicReference<String> targetStackTrace = new AtomicReference<>();
                AtomicInteger sourceErrors = new AtomicInteger(0);
                AtomicInteger targetErrors = new AtomicInteger(0);

                CompletableFuture<Void> sourceTask = processRdbPagesParallel(
                    totalRdbPages, pullLimit, config, currentTime, config.getSourceDb(), 
                    sourceStackTrace, sourceErrors, "SOURCE");

                CompletableFuture<Void> targetTask = processRdbPagesParallel(
                    totalRdbModernPages, pullLimit, config, currentTime, config.getTargetDb(), 
                    targetStackTrace, targetErrors, "TARGET");

                try {
                    CompletableFuture.allOf(sourceTask, targetTask).get();
                } catch (Exception e) {
                    logger.error("Error during parallel processing for table {}: {}", config.getTableName(), e.getMessage());
                    sourceStackTrace.compareAndSet(null, getStackTraceAsString(e));
                    targetStackTrace.compareAndSet(null, getStackTraceAsString(e));
                }

                // Update error tracking
                errorDuringPullingDataSource = sourceErrors.get() > 0;
                errorDuringPullingDataTarget = targetErrors.get() > 0;
                stackTraceSource = sourceStackTrace.get();
                stackTraceTarget = targetStackTrace.get();

                long tableEndTime = System.currentTimeMillis();
                long tableDuration = tableEndTime - tableStartTime;
                logger.info("Completed parallel data pulling for table: {} in {}ms - Source errors: {}, Target errors: {}", 
                           config.getTableName(), tableDuration, sourceErrors.get(), targetErrors.get());

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

                    kafkaProducerService.sendEventToProcessor(pullerEventString, kafkaPropertiesProvider.getProcessorTopicName());
                    logger.info("PULLER IS COMPLETED FOR {}", config.getTableName());

                    config.setRunNow(false);
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

        // ODSE-to-ODSE logic for different tables
        if ("NBS_ODSE".equalsIgnoreCase(config.getSourceDb()) && "NBS_ODSE".equalsIgnoreCase(config.getTargetDb())) {
            sourceCount = odseJdbcTemplate.queryForObject(config.getQueryCount(), Integer.class);
            targetCount = odseJdbcTemplate.queryForObject(config.getTargetQueryCount(), Integer.class);
            if (sourceCount != null && targetCount != null) {
                int totalSourcePages = (int) Math.ceil((double) sourceCount / pullLimit);
                int totalTargetPages = (int) Math.ceil((double) targetCount / pullLimit);

                long tableStartTime = System.currentTimeMillis();
                logger.info("Starting parallel ODSE data pulling for table: {} - Source pages: {}, Target pages: {}", 
                           config.getTableName(), totalSourcePages, totalTargetPages);

                AtomicReference<String> sourceStackTrace = new AtomicReference<>();
                AtomicReference<String> targetStackTrace = new AtomicReference<>();
                AtomicInteger sourceErrors = new AtomicInteger(0);
                AtomicInteger targetErrors = new AtomicInteger(0);

                CompletableFuture<Void> sourceTask = processOdsePagesParallel(
                    totalSourcePages, pullLimit, config, currentTime, config.getQuery(), 
                    config.getTableName(), config.getSourceDb(), sourceStackTrace, sourceErrors, "ODSE_SOURCE");

                CompletableFuture<Void> targetTask = processOdsePagesParallel(
                    totalTargetPages, pullLimit, config, currentTime, config.getTargetQuery(), 
                    config.getTargetTableName(), config.getTargetDb(), targetStackTrace, targetErrors, "ODSE_TARGET");

                try {
                    CompletableFuture.allOf(sourceTask, targetTask).get();
                } catch (Exception e) {
                    logger.error("Error during parallel ODSE processing for tables {}/{}: {}", 
                               config.getTableName(), config.getTargetTableName(), e.getMessage());
                    sourceStackTrace.compareAndSet(null, getStackTraceAsString(e));
                    targetStackTrace.compareAndSet(null, getStackTraceAsString(e));
                }

                // Update error tracking
                errorDuringPullingDataSource = sourceErrors.get() > 0;
                errorDuringPullingDataTarget = targetErrors.get() > 0;
                stackTraceSource = sourceStackTrace.get();
                stackTraceTarget = targetStackTrace.get();

                long tableEndTime = System.currentTimeMillis();
                long tableDuration = tableEndTime - tableStartTime;
                logger.info("Completed parallel ODSE data pulling for tables {}/{} in {}ms - Source errors: {}, Target errors: {}", 
                           config.getTableName(), config.getTargetTableName(), tableDuration, sourceErrors.get(), targetErrors.get());
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

                    kafkaProducerService.sendEventToProcessor(pullerEventString, kafkaPropertiesProvider.getProcessorTopicName());
                    logger.info("PULLER IS COMPLETED FOR {} and {}", config.getTableName(), config.getTargetTableName());

                    config.setRunNow(false);
                    dataCompareConfigRepository.save(config);
                } else {
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


    private CompletableFuture<Void> processRdbPagesParallel(int totalPages, int pullLimit, 
                                                           DataCompareConfig config, Timestamp currentTime, 
                                                           String dbType, AtomicReference<String> stackTraceRef, 
                                                           AtomicInteger errorCount, String logPrefix) {
        
        long dbStartTime = System.currentTimeMillis();
        logger.debug("{} - Starting processing {} pages for table {}", logPrefix, totalPages, config.getTableName());
        
        return CompletableFuture.runAsync(() -> {
            try {
                for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
                    if (errorDuringPullingDataSource) {
                        logger.warn("{} - Stopping processing due to error flag for table {}", logPrefix, config.getTableName());
                        break;
                    }
                    
                    final int currentPageIndex = pageIndex;
                    long pageStartTime = System.currentTimeMillis();
                    
                    try {
                        int startRow = pageIndex * pullLimit + 1;
                        int endRow = (pageIndex + 1) * pullLimit;
                        
                        logger.debug("{} - Processing page {}/{} for table {} (rows {}-{})", 
                                   logPrefix, currentPageIndex + 1, totalPages, config.getTableName(), startRow, endRow);
                        
                        String query = preparingPaginationQuery(config.getQuery(), startRow, endRow);
                        List<Map<String, Object>> returnData = executeQueryForData(query, dbType);
                        
                        String rawJsonData;
                        try {
                            rawJsonData = gson.toJson(returnData);
                            
                        } catch (Exception jsonException) {
                            logger.error("{} - JSON serialization failed for page {}: {}", logPrefix, currentPageIndex + 1, jsonException.getMessage());
                            logger.debug("{} - This may be due to corrupted timestamp data in the database", logPrefix);
                            throw new DataCompareException("JSON serialization failed: " + jsonException.getMessage());
                        }
                        
                        logger.debug("{} - Writing {} records to S3: {}/{}/{}_{}_{}.json", 
                                   logPrefix, returnData.size(), dbType, config.getTableName(), 
                                   new SimpleDateFormat("yyyyMMddHHmmss").format(currentTime), 
                                   config.getTableName(), pageIndex);
                        
                        String uploadResult = storageDataService.persistMultiPart(dbType, rawJsonData,
                                                                                config.getTableName(), currentTime, pageIndex);
                        
                        if (!uploadResult.equals(LOG_SUCCESS)) {
                            throw new DataCompareException("S3 upload failed: " + uploadResult);
                        }
                        
                        logger.debug("{} - Successfully uploaded page {}/{} to S3", logPrefix, currentPageIndex + 1, totalPages);
                        
                        long pageEndTime = System.currentTimeMillis();
                        logger.debug("{} - Page {}/{} completed in {}ms, Records={}", 
                                   logPrefix, currentPageIndex + 1, totalPages, (pageEndTime - pageStartTime), returnData.size());
                        
                    } catch (Exception e) {
                        errorCount.incrementAndGet();
                        stackTraceRef.compareAndSet(null, getStackTraceAsString(e));
                        logger.error("{} - Error processing page {}/{} for table {}: {}", 
                                   logPrefix, currentPageIndex + 1, totalPages, config.getTableName(), e.getMessage());
                        
                        // Set error flag to stop processing
                        errorDuringPullingDataSource = true;
                    }
                }
                
                long dbEndTime = System.currentTimeMillis();
                long dbDuration = dbEndTime - dbStartTime;
                logger.info("{} - Database processing completed for {} in {}ms", 
                          logPrefix, config.getTableName(), dbDuration);
                          
            } catch (Exception e) {
                long dbEndTime = System.currentTimeMillis();
                long dbDuration = dbEndTime - dbStartTime;
                logger.error("{} - Database processing failed for {} after {}ms: {}", 
                           logPrefix, config.getTableName(), dbDuration, e.getMessage());
                throw e;
            }
        }, chunkTaskExecutor);
    }

    private CompletableFuture<Void> processOdsePagesParallel(int totalPages, int pullLimit, 
                                                            DataCompareConfig config, Timestamp currentTime, 
                                                            String query, String tableName, String dbType,
                                                            AtomicReference<String> stackTraceRef, 
                                                            AtomicInteger errorCount, String logPrefix) {
        
        long dbStartTime = System.currentTimeMillis();
        logger.debug("{} - Starting processing {} pages for table {}", logPrefix, totalPages, tableName);
        
        return CompletableFuture.runAsync(() -> {
            try {
                for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
                    if (errorDuringPullingDataSource) {
                        logger.warn("{} - Stopping processing due to error flag for table {}", logPrefix, tableName);
                        break;
                    }
                    
                    final int currentPageIndex = pageIndex;
                    long pageStartTime = System.currentTimeMillis();
                    
                    try {
                        int startRow = pageIndex * pullLimit + 1;
                        int endRow = (pageIndex + 1) * pullLimit;
                        
                        logger.debug("{} - Processing page {}/{} for table {} (rows {}-{})", 
                                   logPrefix, currentPageIndex + 1, totalPages, tableName, startRow, endRow);
                        
                        String paginatedQuery = preparingPaginationQuery(query, startRow, endRow);
                        List<Map<String, Object>> returnData;
                        
                        // Use appropriate JDBC template
                        if ("NBS_ODSE".equalsIgnoreCase(dbType)) {
                            returnData = odseJdbcTemplate.queryForList(paginatedQuery);
                        } else {
                            returnData = executeQueryForData(paginatedQuery, dbType);
                        }
                        
                        String rawJsonData;
                        try {
                            rawJsonData = gson.toJson(returnData);
                        } catch (Exception jsonException) {
                            logger.error("{} - JSON serialization failed for page {}: {}", logPrefix, currentPageIndex + 1, jsonException.getMessage());
                            throw new DataCompareException("JSON serialization failed: " + jsonException.getMessage());
                        }
                        
                        logger.debug("{} - Writing {} records to S3: {}/{}/{}_{}_{}.json", 
                                   logPrefix, returnData.size(), dbType, tableName, 
                                   new SimpleDateFormat("yyyyMMddHHmmss").format(currentTime), 
                                   tableName, pageIndex);
                        
                        String uploadResult = storageDataService.persistMultiPart(dbType, rawJsonData,
                                                                                tableName, currentTime, pageIndex);
                        
                        if (!uploadResult.equals(LOG_SUCCESS)) {
                            throw new DataCompareException("S3 upload failed: " + uploadResult);
                        }
                        
                        logger.debug("{} - Successfully uploaded page {}/{} to S3", logPrefix, currentPageIndex + 1, totalPages);
                        
                        long pageEndTime = System.currentTimeMillis();
                        logger.debug("{} - Page {}/{} completed in {}ms, Records={}", 
                                   logPrefix, currentPageIndex + 1, totalPages, (pageEndTime - pageStartTime), returnData.size());
                        
                    } catch (Exception e) {
                        errorCount.incrementAndGet();
                        stackTraceRef.compareAndSet(null, getStackTraceAsString(e));
                        logger.error("{} - Error processing page {}/{} for table {}: {}", 
                                   logPrefix, currentPageIndex + 1, totalPages, tableName, e.getMessage());
                        
                        // Set error flag to stop processing
                        errorDuringPullingDataSource = true;
                    }
                }
                
                long dbEndTime = System.currentTimeMillis();
                long dbDuration = dbEndTime - dbStartTime;
                logger.info("{} - ODSE processing completed for {} in {}ms", 
                          logPrefix, tableName, dbDuration);
                          
            } catch (Exception e) {
                long dbEndTime = System.currentTimeMillis();
                long dbDuration = dbEndTime - dbStartTime;
                logger.error("{} - ODSE processing failed for {} after {}ms: {}", 
                           logPrefix, tableName, dbDuration, e.getMessage());
                throw e;
            }
        }, chunkTaskExecutor);
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
