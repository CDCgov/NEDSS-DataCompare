package gov.cdc.datacompareprocessor.service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import gov.cdc.datacompareprocessor.configuration.TimestampAdapter;
import gov.cdc.datacompareprocessor.repository.dataCompare.DataCompareLogRepository;
import gov.cdc.datacompareprocessor.repository.dataCompare.model.DataCompareLog;
import gov.cdc.datacompareprocessor.service.interfaces.IDataCompareService;
import gov.cdc.datacompareprocessor.service.interfaces.IStorageDataPullerService;
import gov.cdc.datacompareprocessor.service.model.DifferentModel;
import gov.cdc.datacompareprocessor.service.model.PullerEventModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.lang.reflect.Type;
import java.sql.Timestamp;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import java.util.function.Predicate;

import static gov.cdc.datacompareprocessor.share.StackTraceUtil.getStackTraceAsString;
import static gov.cdc.datacompareprocessor.share.StringHelper.convertStringToList;
import static gov.cdc.datacompareprocessor.share.TimestampHandler.getCurrentTimeStamp;

@Service
public class DataCompareService implements IDataCompareService {
    private static final Logger logger = LoggerFactory.getLogger(DataCompareService.class); //NOSONAR
    @Value("${aws.s3.bucket-name}")
    private String bucketName;
    private final IStorageDataPullerService storageDataPullerService;
    private final Gson gson;
    private final DataCompareLogRepository dataCompareLogRepository;
    private final Executor comparisonTaskExecutor;

    // Potentially can store these unmatched in S3
    private static final Map<String, JsonObject> unmatchedRecordsSource = new HashMap<>();
    private static final Map<String, JsonObject> unmatchedRecordsTarget = new HashMap<>();
    private static Set<String> sourceIdData = new HashSet<>();
    private static Set<String> targetIdData = new HashSet<>();
    public DataCompareService(IStorageDataPullerService storageDataPullerService,
                              DataCompareLogRepository dataCompareLogRepository,
                              @Qualifier("comparisonTaskExecutor") Executor comparisonTaskExecutor) {
        this.storageDataPullerService = storageDataPullerService;
        this.dataCompareLogRepository = dataCompareLogRepository;
        this.comparisonTaskExecutor = comparisonTaskExecutor;
        this.gson = new GsonBuilder()
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampSerializer())
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampDeserializer())
                .serializeNulls()
                .setPrettyPrinting()
                .create();
    }

    public void processingData(PullerEventModel pullerEventModel) {
        long totalStartTime = System.currentTimeMillis();
        logger.info("Starting data comparison for table: {}", pullerEventModel.getSourceFileName());
        
        unmatchedRecordsSource.clear();
        unmatchedRecordsTarget.clear();
        sourceIdData.clear();
        targetIdData.clear();
        Map<String, Integer> maxIndexMapper = getMaxIndexWithSource(pullerEventModel);
        Integer maxIndex = maxIndexMapper.get("maxValue");
        String maxIndexSource = null;
        if (maxIndexMapper.containsKey("source")) {
            int sourceType = maxIndexMapper.get("source");
            if (sourceType == 1) {
                maxIndexSource = pullerEventModel.getFirstLayerRdbFolderName();
            } else if (sourceType == 2) {
                maxIndexSource = pullerEventModel.getFirstLayerRdbModernFolderName();
            } else if (sourceType == 3) {
                maxIndexSource = pullerEventModel.getFirstLayerOdseSourceFolderName();
            }
        }

        List<DifferentModel> differModels = new ArrayList<>();

        String stackTraceSource;
        DataCompareLog logSource = new DataCompareLog();
        String stackTraceTarget;
        DataCompareLog logTarget = new DataCompareLog();


        if ("RDB".equals(pullerEventModel.getFirstLayerRdbFolderName()) && "RDB_MODERN".equals(pullerEventModel.getFirstLayerRdbModernFolderName())) {
            Optional<DataCompareLog> logResultRdb = dataCompareLogRepository.findById(pullerEventModel.getLogIdRdb());
            if (logResultRdb.isPresent()) {
                logSource = logResultRdb.get();
            }

            Optional<DataCompareLog> logResultRdbModern = dataCompareLogRepository.findById(pullerEventModel.getLogIdRdbModern());
            if (logResultRdbModern.isPresent()) {
                logTarget = logResultRdbModern.get();
            }
        }

        if ("NBS_ODSE".equals(pullerEventModel.getFirstLayerOdseSourceFolderName()) && "NBS_ODSE".equals(pullerEventModel.getFirstLayerOdseTargetFolderName())) {
            Optional<DataCompareLog> logResultOdseSource = dataCompareLogRepository.findById(pullerEventModel.getLogIdOdseSource());
            if (logResultOdseSource.isPresent()) {
                logSource = logResultOdseSource.get();
            }

            Optional<DataCompareLog> logResultOdseTarget = dataCompareLogRepository.findById(pullerEventModel.getLogIdOdseTarget());
            if (logResultOdseTarget.isPresent()) {
                logTarget = logResultOdseTarget.get();
            }
        }

        boolean error = false;
        int index = 0;
        long fileComparisonStartTime = System.currentTimeMillis();
        logger.info("Starting file-by-file comparison for {} files", maxIndex);
        
        try {
            final PullerEventModel finalPullerEventModel = pullerEventModel;
            final String finalMaxIndexSource = maxIndexSource;

            int batchSize = 8;
            logger.info("Processing {} files in batches of {}", maxIndex, batchSize);
            
            for (int batchStart = 0; batchStart < maxIndex; batchStart += batchSize) {
                int batchEnd = Math.min(batchStart + batchSize, maxIndex);
                logger.debug("Processing batch: files {} to {}", batchStart, batchEnd - 1);
                
                List<CompletableFuture<List<DifferentModel>>> batchTasks = new ArrayList<>();
                
                for (int i = batchStart; i < batchEnd; i++) {
                    final int fileIndex = i;
                    
                    CompletableFuture<List<DifferentModel>> task = CompletableFuture.supplyAsync(() -> {
                        long fileStartTime = System.currentTimeMillis();
                        
                        try {
                            String sourcePath = "";
                            String targetPath = "";
                            if ("RDB".equals(finalPullerEventModel.getFirstLayerRdbFolderName()) && "RDB_MODERN".equals(finalPullerEventModel.getFirstLayerRdbModernFolderName())) {
                                sourcePath = finalPullerEventModel.getFirstLayerRdbFolderName()
                                        + "/" + finalPullerEventModel.getSecondLayerFolderName()
                                        + "/" + finalPullerEventModel.getThirdLayerFolderName()
                                        + "/" + finalPullerEventModel.getSourceFileName() + "_" + fileIndex + ".json";
                                targetPath  = finalPullerEventModel.getFirstLayerRdbModernFolderName()
                                        + "/" + finalPullerEventModel.getSecondLayerFolderName()
                                        + "/" + finalPullerEventModel.getThirdLayerFolderName()
                                        + "/" + finalPullerEventModel.getSourceFileName() + "_" + fileIndex + ".json";
                            }

                            if ("NBS_ODSE".equals(finalPullerEventModel.getFirstLayerOdseSourceFolderName()) && "NBS_ODSE".equals(finalPullerEventModel.getFirstLayerOdseTargetFolderName())) {
                                sourcePath = finalPullerEventModel.getFirstLayerOdseSourceFolderName()
                                    + "/" + finalPullerEventModel.getSourceFileName()
                                    + "/" + finalPullerEventModel.getThirdLayerFolderName()
                                    + "/" + finalPullerEventModel.getSourceFileName() + "_" + fileIndex + ".json";
                                targetPath  = finalPullerEventModel.getFirstLayerOdseTargetFolderName()
                                    + "/" + finalPullerEventModel.getTargetFileName()
                                    + "/" + finalPullerEventModel.getThirdLayerFolderName()
                                    + "/" + finalPullerEventModel.getTargetFileName() + "_" + fileIndex + ".json";
                            }

                            List<String> ignoreCols = convertStringToList(finalPullerEventModel.getIgnoreColumns());

                            List<String> differFileNames = new ArrayList<>();
                            differFileNames.add(
                                    compareJsonFiles(sourcePath, targetPath, finalPullerEventModel, finalPullerEventModel.getKeyColumn(), fileIndex, ignoreCols, finalMaxIndexSource)
                            );

                            List<DifferentModel> fileResults = new ArrayList<>();
                            for (String differFileName : differFileNames) {
                                JsonElement jsonElement = storageDataPullerService.readJsonFromStorage(differFileName);
                                Type listType = new TypeToken<List<DifferentModel>>() {
                                }.getType();
                                List<DifferentModel> modelList = gson.fromJson(jsonElement, listType);
                                fileResults.addAll(modelList);
                            }

                            long fileEndTime = System.currentTimeMillis();
                            logger.debug("Completed comparison for file {} in {}ms", fileIndex, fileEndTime - fileStartTime);
                            
                            return fileResults;
                            
                        } catch (Exception e) {
                            logger.error("Error processing file {}: {}", fileIndex, e.getMessage());
                            return new ArrayList<DifferentModel>(); // Return empty list on error
                        }
                    }, comparisonTaskExecutor);
                    
                    batchTasks.add(task);
                }
                
                logger.debug("Waiting for batch of {} tasks to complete...", batchTasks.size());
                for (CompletableFuture<List<DifferentModel>> task : batchTasks) {
                    try {
                        List<DifferentModel> result = task.get();
                        differModels.addAll(result);
                    } catch (Exception e) {
                        logger.error("Error waiting for batch task: {}", e.getMessage());
                    }
                }
                
                logger.debug("Completed batch: files {} to {}", batchStart, batchEnd - 1);
                index = batchEnd - 1;
            }

            long fileComparisonEndTime = System.currentTimeMillis();
            logger.info("Completed file-by-file comparison in {}ms. Processing remaining data...", 
                       fileComparisonEndTime - fileComparisonStartTime);

            long remainingStartTime = System.currentTimeMillis();
            var ignoreColList =  convertStringToList(pullerEventModel.getIgnoreColumns());
            var modelList = compareJsonFilesOnRemaining( pullerEventModel.getKeyColumn(), ignoreColList);
            differModels.addAll(modelList);

            var remainList = processingRemainingData( ignoreColList,  pullerEventModel.getKeyColumn(), pullerEventModel.getSourceFileName());
            differModels.addAll(remainList);
            
            long remainingEndTime = System.currentTimeMillis();
            logger.info("Completed remaining data processing in {}ms", remainingEndTime - remainingStartTime);

            Predicate<DifferentModel> sourcePredicate = r -> r.getMissingColumn() != null && r.getMissingColumn().contains("is not exist in SOURCE_TABLE");
            Predicate<DifferentModel> targetPredicate = r -> r.getMissingColumn() != null && r.getMissingColumn().contains("is not exist in TARGET_TABLE");
            processFirstFound(differModels, sourcePredicate);
            processFirstFound(differModels, targetPredicate);

            differModels.sort(Comparator.comparing(DifferentModel::getKey, Comparator.nullsFirst(Comparator.naturalOrder())));

            var stringValue = gson.toJson(differModels);

            if ("RDB".equals(pullerEventModel.getFirstLayerRdbFolderName()) && "RDB_MODERN".equals(pullerEventModel.getFirstLayerRdbModernFolderName())) {
                storageDataPullerService.uploadDataToStorage(
                        pullerEventModel.getFirstLayerRdbModernFolderName(),
                        pullerEventModel.getSecondLayerFolderName(),
                        pullerEventModel.getThirdLayerFolderName(),
                        "DIFFERENCE",
                        "differences.json", stringValue);
            }

            if ("NBS_ODSE".equals(pullerEventModel.getFirstLayerOdseSourceFolderName()) && "NBS_ODSE".equals(pullerEventModel.getFirstLayerOdseTargetFolderName())) {
                storageDataPullerService.uploadDataToStorage(
                        pullerEventModel.getFirstLayerOdseTargetFolderName(),
                        pullerEventModel.getSecondLayerFolderName(),
                        pullerEventModel.getThirdLayerFolderName(),
                        "DIFFERENCE",
                        "differences.json", stringValue);

            }
        }
        catch (Exception e)
        {
            error = true;
            logger.error("Error during data comparison: {}", e.getMessage());
            stackTraceSource = getStackTraceAsString(e);
            stackTraceTarget = getStackTraceAsString(e);
            logSource.setStatusDesc(stackTraceSource);
            logTarget.setStatusDesc(stackTraceTarget);
            logSource.setStatus("Error");
            logTarget.setStatus("Error");
        }

        logSource.setRowsCompared(sourceIdData.size());
        logTarget.setRowsCompared(targetIdData.size());

        var currentTime = getCurrentTimeStamp();
        logSource.setEndDateTime(currentTime);
        logTarget.setEndDateTime(currentTime);

        if ("RDB".equals(pullerEventModel.getFirstLayerRdbFolderName()) && "RDB_MODERN".equals(pullerEventModel.getFirstLayerRdbModernFolderName())) {
            var rdbPath = pullerEventModel.getFirstLayerRdbFolderName() + "/" + pullerEventModel.getSecondLayerFolderName() + "/" + pullerEventModel.getThirdLayerFolderName();
            var rdbModernPath = pullerEventModel.getFirstLayerRdbModernFolderName() + "/" + pullerEventModel.getSecondLayerFolderName() + "/" + pullerEventModel.getThirdLayerFolderName();
            logSource.setFileLocation(rdbPath);
            logTarget.setFileLocation(rdbModernPath);
        }
        if ("NBS_ODSE".equals(pullerEventModel.getFirstLayerOdseSourceFolderName()) && "NBS_ODSE".equals(pullerEventModel.getFirstLayerOdseTargetFolderName())) {

            var odseSourcePath = pullerEventModel.getFirstLayerOdseSourceFolderName() + "/" + pullerEventModel.getSourceFileName() + "/" + pullerEventModel.getThirdLayerFolderName();
            var odseTargetPath = pullerEventModel.getFirstLayerOdseTargetFolderName() + "/" + pullerEventModel.getTargetFileName() + "/" + pullerEventModel.getThirdLayerFolderName();
            logSource.setFileLocation(odseSourcePath);
            logTarget.setFileLocation(odseTargetPath);
        }

        if (!error) {
            logSource.setStatus("Complete");
            logTarget.setStatus("Complete");
        }

        dataCompareLogRepository.save(logSource);
        dataCompareLogRepository.save(logTarget);
        
        long totalEndTime = System.currentTimeMillis();
        logger.info("Data comparison completed for table: {} in {}ms. Total differences found: {}", 
                   pullerEventModel.getSourceFileName(), totalEndTime - totalStartTime, differModels.size());
    }

    private void processFirstFound(List<DifferentModel> records, Predicate<DifferentModel> predicate) {
        Optional<DifferentModel> firstFound = records.stream()
                .filter(predicate)
                .peek(r -> r.setKey(null))
                .findFirst();

        if (firstFound.isPresent()) {
            // Remove all that match the predicate
            records.removeIf(predicate);

            // Add the first found back to the list
            records.add(firstFound.get());
        }
    }

    protected Map<String, Integer> getMaxIndexWithSource(PullerEventModel pullerEventModel) {
        Map<String, Integer> result = new HashMap<>();

        // Determine the max value and source
        int maxValue = 0;
        String source = "";

        if (pullerEventModel.getRdbMaxIndex() != null && pullerEventModel.getRdbModernMaxIndex() != null) {
            if (pullerEventModel.getRdbMaxIndex() >= pullerEventModel.getRdbModernMaxIndex()) {
                maxValue = pullerEventModel.getRdbMaxIndex();
                source = pullerEventModel.getFirstLayerRdbFolderName();
            } else {
                maxValue = pullerEventModel.getRdbModernMaxIndex();
                source = pullerEventModel.getFirstLayerRdbModernFolderName();
            }
        } else if (pullerEventModel.getRdbMaxIndex() != null) {
            maxValue = pullerEventModel.getRdbMaxIndex();
            source = pullerEventModel.getFirstLayerRdbFolderName();
        } else if (pullerEventModel.getRdbModernMaxIndex() != null) {
            maxValue = pullerEventModel.getRdbModernMaxIndex();
            source = pullerEventModel.getFirstLayerRdbModernFolderName();
        } else {
            logger.warn("Both rdbMaxIndex and rdbModernMaxIndex are null.");
        }

        if (pullerEventModel.getOdseSourceMaxIndex() != null && pullerEventModel.getOdseTargetMaxIndex() != null) {
            if (pullerEventModel.getOdseSourceMaxIndex() >= pullerEventModel.getOdseTargetMaxIndex()) {
                maxValue = pullerEventModel.getOdseSourceMaxIndex();
                source = pullerEventModel.getFirstLayerOdseSourceFolderName();
            } else {
                maxValue = pullerEventModel.getOdseTargetMaxIndex();
                source = pullerEventModel.getFirstLayerOdseSourceFolderName();
            }
        } else if (pullerEventModel.getOdseSourceMaxIndex() != null) {
            maxValue = pullerEventModel.getOdseSourceMaxIndex();
            source = pullerEventModel.getFirstLayerOdseSourceFolderName();
        } else if (pullerEventModel.getOdseTargetMaxIndex() != null) {
            maxValue = pullerEventModel.getOdseTargetMaxIndex();
            source = pullerEventModel.getFirstLayerOdseSourceFolderName();
        } else {
            logger.warn("Both odseSourceMaxIndex and odseTargetMaxIndex are null.");
        }

        // Store max value and source in the map
        result.put("maxValue", maxValue);

        if(source.equals(pullerEventModel.getFirstLayerRdbFolderName())) {
            result.put("source", 1);
        }
        if(source.equals(pullerEventModel.getFirstLayerRdbModernFolderName())) {
            result.put("source", 2);
        }
        if(source.equals(pullerEventModel.getFirstLayerOdseSourceFolderName())) {
            result.put("source", 3);
        }

        return result;
    }

    protected List<DifferentModel> processingRemainingData(List<String> ignoreCols, String uniqueIdField, String tableName) {
        StringBuilder diffBuilder = new StringBuilder();
        List<DifferentModel> differentModels = new ArrayList<>();

        Map<String, JsonObject> mapSource =  new HashMap<>();
        Map<String, JsonObject> mapRdbModern = new HashMap<>();

        if (!unmatchedRecordsSource.isEmpty()) {
            mapSource.putAll(unmatchedRecordsSource);
        }

        if (!unmatchedRecordsTarget.isEmpty()) {
            mapRdbModern.putAll(unmatchedRecordsTarget);
        }
        unmatchedRecordsSource.clear();;
        unmatchedRecordsTarget.clear();

        for(String id: mapSource.keySet())
        {
            DifferentModel differentModel = new DifferentModel();
            diffBuilder.setLength(0);
            diffBuilder.append("NO RECORD FOUND IN TARGET_TABLE");

            differentModel.setTable(tableName);
            differentModel.setKey(id);
            differentModel.setKeyColumn(uniqueIdField);
            differentModel.setDifferentColumnAndValue(diffBuilder.toString().replaceAll("\"", ""));
            differentModels.add(differentModel);

        }

        for(String id: mapRdbModern.keySet())
        {
            DifferentModel differentModel = new DifferentModel();
            diffBuilder.setLength(0);
            diffBuilder.append("NO RECORD FOUND IN SOURCE_TABLE");
            differentModel.setTable(tableName);
            differentModel.setKey(id);
            differentModel.setKeyColumn(uniqueIdField);
            differentModel.setDifferentColumnAndValue(diffBuilder.toString().replaceAll("\"", ""));
            differentModels.add(differentModel);

        }

        return differentModels;
    }

    protected List<DifferentModel> compareJsonFilesOnRemaining(String uniqueIdField, List<String> ignoreCols)
    {
        Map<String, JsonObject> mapSource = new HashMap<>();
        Map<String, JsonObject> mapTarget = new HashMap<>();

        if (!unmatchedRecordsSource.isEmpty()) {
            mapSource.putAll(unmatchedRecordsSource);
        }


        if (!unmatchedRecordsTarget.isEmpty()) {
            mapTarget.putAll(unmatchedRecordsTarget);
        }

        unmatchedRecordsSource.clear();;
        unmatchedRecordsTarget.clear();


        StringBuilder diffBuilder = new StringBuilder();
        StringBuilder missingColBuilder = new StringBuilder();
        List<DifferentModel> differentModels = new ArrayList<>();

        StringBuilder nullValueColBuilder = new StringBuilder();

        if (mapSource.size() < mapTarget.size()) {
            for (String id : mapSource.keySet()) {
                if (mapTarget.containsKey(id)) {
                    DifferentModel differentModel = new DifferentModel();
                    JsonObject recordSource = mapSource.get(id);
                    JsonObject recordTarget = mapTarget.get(id);
                    mapSource.remove(id);
                    mapTarget.remove(id);
                    List<String> differList = new ArrayList<>();
                    List<String> missingColList = new ArrayList<>();
                    List<String> nullValueColList = new ArrayList<>();

                    for (String key : recordSource.keySet()) {
                        if (ignoreCols.contains(key)) {
                            continue;
                        }

                        // Get value from specific column
                        JsonElement valueSource = recordSource.get(key);
                        JsonElement valueTarget = recordTarget.get(key);
                        recordSource.remove(key);
                        recordTarget.remove(key);
                        if (valueSource==null && valueTarget==null){
                            nullValueColBuilder.setLength(0);
                            nullValueColBuilder.append(key);
                            nullValueColList.add(nullValueColBuilder.toString());
                        }
                        if (!valueSource.equals(valueTarget)) {


                            if (valueTarget != null) {
                                diffBuilder.setLength(0);
                                diffBuilder.append(key).append(": ")
                                        .append("[SOURCE_VALUE: ").append(valueSource).append("], ")
                                        .append("[TARGET_VALUE: ").append(valueTarget).append("]").trimToSize();
                                differList.add(diffBuilder.toString());

                            }
                            else {
                                missingColBuilder.setLength(0);
                                missingColBuilder.append(key).append(" is not exist in TARGET_TABLE").trimToSize();
                                missingColList.add(missingColBuilder.toString());
                            }

                        }
                    }
                    nullValueColBuilder.setLength(0);
                    nullValueColBuilder.append("[");
                    for (int i = 0; i < nullValueColList.size(); i++) {

                        nullValueColBuilder.append(nullValueColList.get(i));
                        // Add a comma if it's not the last element
                        if (i < nullValueColList.size() - 1) {
                            nullValueColBuilder.append(",");
                        }
                    }
                    nullValueColBuilder.append("]");

                    diffBuilder.setLength(0);
                    diffBuilder.append("[");
                    for (int i = 0; i < differList.size(); i++) {

                        diffBuilder.append(differList.get(i));
                        // Add a comma if it's not the last element
                        if (i < differList.size() - 1) {
                            diffBuilder.append(",");
                        }
                    }
                    diffBuilder.append("]");

                    missingColBuilder.setLength(0);
                    missingColBuilder.append("[");
                    for (int i = 0; i < missingColList.size(); i++) {

                        missingColBuilder.append(missingColList.get(i));
                        // Add a comma if it's not the last element
                        if (i < missingColList.size() - 1) {
                            missingColBuilder.append(",");
                        }
                    }
                    missingColBuilder.append("]");
                    differentModel.setMissingColumn(missingColBuilder.toString().replaceAll("\"", ""));
                    differentModel.setNullValueColumns(nullValueColBuilder.toString().replaceAll("\"", ""));

                    differentModel.setKey(id);
                    differentModel.setKeyColumn(uniqueIdField);
                    differentModel.setDifferentColumnAndValue(diffBuilder.toString().replaceAll("\"", ""));
                    if (!differentModel.getDifferentColumnAndValue().equals("[]"))
                    {
                        differentModels.add(differentModel);
                    }
                    else if (!differentModel.getMissingColumn().equals("[]"))
                    {
                        differentModels.add(differentModel);
                    }
                    else if (!differentModel.getNullValueColumns().equals("[]"))
                    {
                        differentModels.add(differentModel);
                    }


                }

            }
        }
        else {
            for (String id : mapTarget.keySet()) {
                if (mapSource.containsKey(id)) {
                    DifferentModel differentModel = new DifferentModel();
                    JsonObject recordSource = mapSource.get(id);
                    JsonObject recordTarget = mapTarget.get(id);
                    mapSource.remove(id);
                    mapTarget.remove(id);
                    List<String> differList = new ArrayList<>();
                    List<String> missingColList = new ArrayList<>();
                    List<String> nullValueColList = new ArrayList<>();
                    for (String key : mapTarget.keySet()) {
                        if (ignoreCols.contains(key)) {
                            continue;
                        }

                        // Get value from specific column
                        JsonElement valueSource = recordSource.get(key);
                        JsonElement valueTarget = recordTarget.get(key);

                        recordSource.remove(key);
                        recordTarget.remove(key);
                        if (valueSource==null && valueTarget==null){
                            nullValueColBuilder.setLength(0);
                            nullValueColBuilder.append(key);
                            nullValueColList.add(nullValueColBuilder.toString());
                        }
                        if (!valueTarget.equals(valueSource)) {


                            if (valueSource != null) {
                                diffBuilder.setLength(0);
                                diffBuilder.append(key).append(": ")
                                        .append("[SOURCE_VALUE: ").append(valueSource).append("], ")
                                        .append("[TARGET_VALUE: ").append(valueTarget).append("]").trimToSize();
                                differList.add(diffBuilder.toString());

                            }
                            else {
                                missingColBuilder.setLength(0);
                                missingColBuilder.append(key).append(" is not exist in SOURCE_TABLE").trimToSize();
                                missingColList.add(missingColBuilder.toString());
                            }

                        }
                    }
                    nullValueColBuilder.setLength(0);
                    nullValueColBuilder.append("[");
                    for (int i = 0; i < nullValueColList.size(); i++) {

                        nullValueColBuilder.append(nullValueColList.get(i));
                        // Add a comma if it's not the last element
                        if (i < nullValueColList.size() - 1) {
                            nullValueColBuilder.append(",");
                        }
                    }
                    nullValueColBuilder.append("]");
                    diffBuilder.setLength(0);
                    diffBuilder.append("[");
                    for (int i = 0; i < differList.size(); i++) {

                        diffBuilder.append(differList.get(i));
                        // Add a comma if it's not the last element
                        if (i < differList.size() - 1) {
                            diffBuilder.append(",");
                        }
                    }
                    diffBuilder.append("]");

                    missingColBuilder.setLength(0);
                    missingColBuilder.append("[");
                    for (int i = 0; i < missingColList.size(); i++) {

                        missingColBuilder.append(missingColList.get(i));
                        // Add a comma if it's not the last element
                        if (i < missingColList.size() - 1) {
                            missingColBuilder.append(",");
                        }
                    }
                    missingColBuilder.append("]");
                    differentModel.setMissingColumn(missingColBuilder.toString().replaceAll("\"", ""));

                    differentModel.setMissingColumn(missingColBuilder.toString().replaceAll("\"", ""));


                    differentModel.setKey(id);
                    differentModel.setKeyColumn(uniqueIdField);
                    differentModel.setDifferentColumnAndValue(diffBuilder.toString().replaceAll("\"", ""));

                    if (!differentModel.getDifferentColumnAndValue().equals("[]")) {
                        differentModels.add(differentModel);
                    }
                    else if (!differentModel.getMissingColumn().equals("[]"))
                    {
                        differentModels.add(differentModel);
                    }
                    else if (!differentModel.getNullValueColumns().equals("[]"))
                    {
                        differentModels.add(differentModel);
                    }

                }

            }
        }

        if (!mapSource.isEmpty()) {
            unmatchedRecordsSource.putAll(mapSource);
        }

        if(!mapTarget.isEmpty()) {
            unmatchedRecordsTarget.putAll(mapTarget);
        }
        return differentModels;
    }

    /**
     * Max indicate the table that will be used as the subject to be compared against, depending on number of records tables, max can be table from RDB or RDB Modern
     * */
    protected String compareJsonFiles(String fileSourcePath, String fileTargetPath, PullerEventModel pullerEventModel, String uniqueIdField,
                                      int index, List<String> ignoreCols, String maxSource)
    {
        Map<String, JsonObject> mapSource = loadJsonAsMapFromS3(fileSourcePath, uniqueIdField);
        Map<String, JsonObject> mapTarget = loadJsonAsMapFromS3(fileTargetPath, uniqueIdField);

        if (!unmatchedRecordsSource.isEmpty()) {
            mapSource.putAll(unmatchedRecordsSource);
            unmatchedRecordsSource.clear();;
        }

        if (!unmatchedRecordsTarget.isEmpty()) {
            mapTarget.putAll(unmatchedRecordsTarget);
            unmatchedRecordsTarget.clear();
        }

        StringBuilder diffBuilder = new StringBuilder();
        StringBuilder missingColBuilder = new StringBuilder();
        StringBuilder nullValueColBuilder = new StringBuilder();
        List<DifferentModel> differentModels = new ArrayList<>();


        // Compare records in both files
        for (String id : mapSource.keySet()) {
            DifferentModel differentModel = new DifferentModel();
            differentModel.setTable(pullerEventModel.getSourceFileName());
            List<String> differList = new ArrayList<>();
            List<String> missingColList = new ArrayList<>();

            List<String> nullValueColList = new ArrayList<>();

            JsonObject recordSource = mapSource.get(id);
            sourceIdData.add(id);
            JsonObject recordTarget = mapTarget.get(id);
            var newModernRdbRecord = new HashMap<String, JsonObject>();

            if (recordTarget == null) {
                unmatchedRecordsSource.put(id, recordSource);  // Retain unmatched records from A in memory
                continue;
            }


            /// HERE: key is column name
            for (String key : recordSource.keySet()) {
                if (ignoreCols.contains(key)) {
                    continue;
                }

                // Get value from specific column
                JsonElement valueSource = recordSource.get(key);
                JsonElement valueTarget = recordTarget.get(key);
                recordTarget.remove(key);
                if (valueSource==null && valueTarget == null){
                    nullValueColBuilder.setLength(0);
                    nullValueColBuilder.append(key);
                    nullValueColList.add(nullValueColBuilder.toString());
                }
                if (!valueSource.equals(valueTarget)) {
                    if (valueTarget != null) {
                        diffBuilder.setLength(0);
                        diffBuilder.append(key).append(": ")
                                .append("[SOURCE_VALUE: ").append(valueSource).append("], ")
                                .append("[TARGET_VALUE: ").append(valueTarget).append("]").trimToSize();
                        differList.add(diffBuilder.toString());

                    }
                    else {
                        missingColBuilder.setLength(0);
                        missingColBuilder.append(key).append(" is not exist in TARGET_TABLE").trimToSize();
                        missingColList.add(missingColBuilder.toString());
                    }

                }

            }

            if (!recordTarget.isEmpty()) {
                for(String key: recordTarget.keySet())
                {
                    if (ignoreCols.contains(key)) {
                        continue;
                    }

                    missingColBuilder.setLength(0);
                    missingColBuilder.append(key).append(" is not exist in SOURCE_TABLE").trimToSize();
                    missingColList.add(missingColBuilder.toString());


                }
            }


            nullValueColBuilder.setLength(0);
            nullValueColBuilder.append("[");
            for (int i = 0; i < nullValueColList.size(); i++) {

                nullValueColBuilder.append(nullValueColList.get(i));
                // Add a comma if it's not the last element
                if (i < nullValueColList.size() - 1) {
                    nullValueColBuilder.append(",");
                }
            }
            nullValueColBuilder.append("]");

            diffBuilder.setLength(0);
            diffBuilder.append("[");
            for (int i = 0; i < differList.size(); i++) {

                diffBuilder.append(differList.get(i));
                // Add a comma if it's not the last element
                if (i < differList.size() - 1) {
                    diffBuilder.append(",");
                }
            }
            diffBuilder.append("]");

            missingColBuilder.setLength(0);
            missingColBuilder.append("[");
            for (int i = 0; i < missingColList.size(); i++) {

                missingColBuilder.append(missingColList.get(i));
                // Add a comma if it's not the last element
                if (i < missingColList.size() - 1) {
                    missingColBuilder.append(",");
                }
            }
            missingColBuilder.append("]");
            differentModel.setMissingColumn(missingColBuilder.toString().replaceAll("\"", ""));

            differentModel.setNullValueColumns(nullValueColBuilder.toString().replaceAll("\"", ""));

            differentModel.setKey(id);
            differentModel.setKeyColumn(uniqueIdField);
            differentModel.setDifferentColumnAndValue(diffBuilder.toString().replaceAll("\"", ""));

            if (!differentModel.getDifferentColumnAndValue().equals("[]")) {
                differentModels.add(differentModel);
            } else if (!differentModel.getMissingColumn().equals("[]")) {
                differentModels.add(differentModel);
            } else if (!differentModel.getNullValueColumns().equals("[]")) {
                differentModels.add(differentModel);
            }
        }


        // Identify records present only in File B and retain them in memory
        for (String id : mapTarget.keySet()) {
            targetIdData.add(id);
            if (!mapSource.containsKey(id)) {
                unmatchedRecordsTarget.put(id, mapTarget.get(id));
            }
        }

        var stringValue = gson.toJson(differentModels);
        // Persist the differences to S3
        return storageDataPullerService.uploadDataToStorage(
                pullerEventModel.getFirstLayerRdbModernFolderName(),
                pullerEventModel.getSecondLayerFolderName(),
                pullerEventModel.getThirdLayerFolderName(),
                "DIFFERENCE",
                "differences_" + index + ".json", stringValue);
    }
    protected Map<String, JsonObject> loadJsonAsMapFromS3(String fileName, String uniqueIdField) {
        JsonElement jsonElement = storageDataPullerService.readJsonFromStorage(fileName);
        Map<String, JsonObject> recordMap = new HashMap<>();

        try {
            for (JsonElement element : jsonElement.getAsJsonArray()) {
                JsonObject jsonObject = element.getAsJsonObject();
                String id = jsonObject.has(uniqueIdField) && !jsonObject.get(uniqueIdField).isJsonNull()
                        ? jsonObject.get(uniqueIdField).getAsString()
                        : "NULL";
                recordMap.put(id, jsonObject);
            }
        } catch (Exception e) {
            logger.info(e.getMessage());
        }

        return recordMap;
    }
}