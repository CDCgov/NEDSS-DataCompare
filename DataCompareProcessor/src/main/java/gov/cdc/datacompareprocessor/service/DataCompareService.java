package gov.cdc.datacompareprocessor.service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import gov.cdc.datacompareprocessor.configuration.TimestampAdapter;
import gov.cdc.datacompareprocessor.kafka.KafkaProducerService;
import gov.cdc.datacompareprocessor.repository.dataCompare.DataCompareLogRepository;
import gov.cdc.datacompareprocessor.repository.dataCompare.model.DataCompareLog;
import gov.cdc.datacompareprocessor.service.interfaces.IDataCompareService;
import gov.cdc.datacompareprocessor.service.interfaces.IS3DataPullerService;
import gov.cdc.datacompareprocessor.service.model.DifferentModel;
import gov.cdc.datacompareprocessor.service.model.EmailEventModel;
import gov.cdc.datacompareprocessor.service.model.PullerEventModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.lang.reflect.Type;
import java.sql.Timestamp;
import java.util.*;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import static gov.cdc.datacompareprocessor.share.StackTraceUtil.getStackTraceAsString;
import static gov.cdc.datacompareprocessor.share.StringHelper.convertStringToList;
import static gov.cdc.datacompareprocessor.share.TimestampHandler.getCurrentTimeStamp;

@Service
public class DataCompareService implements IDataCompareService {
    private static final Logger logger = LoggerFactory.getLogger(DataCompareService.class); //NOSONAR
    @Value("${aws.s3.bucket-name}")
    private String bucketName;
    private final IS3DataPullerService s3DataPullerService;
    private final Gson gson;

    private final DataCompareLogRepository dataCompareLogRepository;

    // Potentially can store these unmatched in S3
    private static final Map<String, JsonObject> unmatchedRecordsRdb = new HashMap<>();
    private static final Map<String, JsonObject> unmatchedRecordsRdbModern = new HashMap<>();

    private final KafkaProducerService kafkaProducerService;
    @Value("${kafka.topic.data-compare-email-topic}")
    String emailTopicName = "";

    public DataCompareService(IS3DataPullerService s3DataPullerService, DataCompareLogRepository dataCompareLogRepository, KafkaProducerService kafkaProducerService) {
        this.s3DataPullerService = s3DataPullerService;
        this.dataCompareLogRepository = dataCompareLogRepository;
        this.kafkaProducerService = kafkaProducerService;
        this.gson = new GsonBuilder()
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampSerializer())
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampDeserializer())
                .serializeNulls()
                .setPrettyPrinting()
                .create();
    }

    public void processingData(PullerEventModel pullerEventModel) {
        unmatchedRecordsRdb.clear();
        unmatchedRecordsRdbModern.clear();
        Map<String, Integer> maxIndexMapper = getMaxIndexWithSource(pullerEventModel);
        Integer maxIndex = maxIndexMapper.get("maxValue");
        String maxIndexSource = maxIndexMapper.get("source") == 1
                ? pullerEventModel.getFirstLayerRdbFolderName()
                : pullerEventModel.getFirstLayerRdbModernFolderName();

        List<DifferentModel> differModels = new ArrayList<>();


        Optional<DataCompareLog> logResultRdb = dataCompareLogRepository.findById(pullerEventModel.getLogIdRdb());
        DataCompareLog logRdb = new DataCompareLog();
        String stackTrace;
        if (logResultRdb.isPresent()) {
            logRdb = logResultRdb.get();
        }

        Optional<DataCompareLog> logResultRdbModern = dataCompareLogRepository.findById(pullerEventModel.getLogIdRdbModern());
        DataCompareLog logRdbModern = new DataCompareLog();
        String stackTraceModern;
        if (logResultRdbModern.isPresent()) {
            logRdbModern = logResultRdbModern.get();
        }


        boolean error = false;
        int index = 0;
        try {
            for (int i = 0; i < maxIndex; i++) {
                String rdbFile = pullerEventModel.getFirstLayerRdbFolderName()
                        + "/" + pullerEventModel.getSecondLayerFolderName()
                        + "/" + pullerEventModel.getThirdLayerFolderName()
                        + "/" + pullerEventModel.getFileName() + "_" + i + ".json";
                String rdbModernFile  = pullerEventModel.getFirstLayerRdbModernFolderName()
                        + "/" + pullerEventModel.getSecondLayerFolderName()
                        + "/" + pullerEventModel.getThirdLayerFolderName()
                        + "/" + pullerEventModel.getFileName() + "_" + i + ".json";

                List<String> ignoreCols = convertStringToList(pullerEventModel.getIgnoreColumns());

                List<String> differFileNames = new ArrayList<>();
                differFileNames.add(
                        compareJsonFiles(rdbFile, rdbModernFile, pullerEventModel, pullerEventModel.getKeyColumn(), i, ignoreCols, maxIndexSource)
                );

                for (String differFileName : differFileNames) {
                    JsonElement jsonElement = s3DataPullerService.readJsonFromS3(differFileName);
                    Type listType = new TypeToken<List<DifferentModel>>() {
                    }.getType();
                    List<DifferentModel> modelList = gson.fromJson(jsonElement, listType);
                    differModels.addAll(
                            modelList
                    );
                }

                index = i;
            }

            var ignoreColList =  convertStringToList(pullerEventModel.getIgnoreColumns());
            var modelList = compareJsonFilesOnRemaining( pullerEventModel.getKeyColumn(), ignoreColList);
            differModels.addAll(modelList);


            var remainList = processingRemainingData( ignoreColList,  pullerEventModel.getKeyColumn(), pullerEventModel.getFileName());
            differModels.addAll(remainList);

            Predicate<DifferentModel> rdbPredicate = r -> r.getMissingColumn() != null && r.getMissingColumn().contains("is not exist in RDB");
            Predicate<DifferentModel> rdbModernPredicate = r -> r.getMissingColumn() != null && r.getMissingColumn().contains("is not exist in RDB_MODERN");

            processFirstFound(differModels, rdbPredicate);
            processFirstFound(differModels, rdbModernPredicate);

            differModels.sort(Comparator.comparing(DifferentModel::getKey, Comparator.nullsFirst(Comparator.naturalOrder())));

            var stringValue = gson.toJson(differModels);
            s3DataPullerService.uploadDataToS3(
                    pullerEventModel.getFirstLayerRdbModernFolderName(),
                    pullerEventModel.getSecondLayerFolderName(),
                    pullerEventModel.getThirdLayerFolderName(),
                    "DIFFERENCE",
                    "differences.json", stringValue);

            // TODO: create object with info to pull from S3 and invoke the event

            EmailEventModel emailEventModel = new EmailEventModel();
            emailEventModel.setBucketName(bucketName);
            emailEventModel.setRdbPath(pullerEventModel.getFirstLayerRdbFolderName() + "/" + pullerEventModel.getSecondLayerFolderName() + "/" + pullerEventModel.getThirdLayerFolderName());
            emailEventModel.setRdbModernPath(pullerEventModel.getFirstLayerRdbModernFolderName() + "/" + pullerEventModel.getSecondLayerFolderName() + "/" + pullerEventModel.getThirdLayerFolderName());
            emailEventModel.setDifferentFile(pullerEventModel.getFirstLayerRdbModernFolderName() + "/" + pullerEventModel.getSecondLayerFolderName() + "/" + pullerEventModel.getThirdLayerFolderName() + "/DIFFERENCE/differences.json");
            emailEventModel.setFileName(pullerEventModel.getSecondLayerFolderName());
            var stringEmailModel = gson.toJson(emailEventModel);
            kafkaProducerService.sendEventToProcessor(stringEmailModel, emailTopicName);
        }
        catch (Exception e)
        {
            error = true;
            logger.info("ERROR: {}", e.getMessage());
            stackTrace = getStackTraceAsString(e);
            stackTraceModern = getStackTraceAsString(e);
            logRdb.setStatusDesc(stackTrace);
            logRdbModern.setStatusDesc(stackTraceModern);
            logRdb.setStatus("Error");
            logRdbModern.setStatus("Error");
        }

        var currentTime = getCurrentTimeStamp();
        logRdb.setEndDateTime(currentTime);
        logRdbModern.setEndDateTime(currentTime);

        var rdbPath = pullerEventModel.getFirstLayerRdbFolderName() + "/" + pullerEventModel.getSecondLayerFolderName() + "/" + pullerEventModel.getThirdLayerFolderName();
        var rdbModernPath = pullerEventModel.getFirstLayerRdbModernFolderName() + "/" + pullerEventModel.getSecondLayerFolderName() + "/" + pullerEventModel.getThirdLayerFolderName();
        logRdb.setFileLocation(rdbPath);
        logRdbModern.setFileLocation(rdbModernPath);

        if (!error) {
            logRdb.setStatus("Complete");
            logRdbModern.setStatus("Complete");
        }

        dataCompareLogRepository.save(logRdb);
        dataCompareLogRepository.save(logRdbModern);

    }

    private void processFirstFound(List<DifferentModel> records, Predicate<DifferentModel> predicate) {
        Optional<DifferentModel> firstFound = records.stream()
                .filter(predicate)
                .peek(r -> r.setKey(null))
                .peek(r -> r.setDifferentColumnAndValue("[]"))
                .findFirst();

        if (firstFound.isPresent()) {
            // Update or delete records based on the differentColumnAndValue condition
            records.removeIf(record -> {
                if (predicate.test(record)) {
                    if (record.getDifferentColumnAndValue() != null && !record.getDifferentColumnAndValue().equalsIgnoreCase("[]")) {
                        // Update missingColumn to an empty string
                        record.setMissingColumn("");
                        return false; // Do not remove
                    } else {
                        // Remove record as differentColumnAndValue is empty
                        return true; // Remove
                    }
                }
                return false; // Keep if predicate does not match
            });

            // Add the first found back to the list
            records.add(firstFound.get());
        }

//        if (firstFound.isPresent()) {
//            // Remove all that match the predicate
//            records.removeIf(predicate);
//
//            // Add the first found back to the list
//            records.add(firstFound.get());
//        }
    }

    protected Map<String, Integer> getMaxIndexWithSource(PullerEventModel pullerEventModel) {
        Map<String, Integer> result = new HashMap<>();

        // Determine the max value and source
        int maxValue;
        String source;

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
            throw new IllegalStateException("Both rdbMaxIndex and rdbModernMaxIndex are null.");
        }

        // Store max value and source in the map
        result.put("maxValue", maxValue);
        result.put("source", source.equals(pullerEventModel.getFirstLayerRdbFolderName()) ? 1 : 2); // 1 for rdbMax, 2 for rdbModernMax

        return result;
    }

    protected List<DifferentModel> processingRemainingData(List<String> ignoreCols, String uniqueIdField, String tableName) {
        StringBuilder diffBuilder = new StringBuilder();
        List<DifferentModel> differentModels = new ArrayList<>();

        Map<String, JsonObject> mapRdb =  new HashMap<>();
        Map<String, JsonObject> mapRdbModern = new HashMap<>();

        if (!unmatchedRecordsRdb.isEmpty()) {
            mapRdb.putAll(unmatchedRecordsRdb);
        }

        if (!unmatchedRecordsRdbModern.isEmpty()) {
            mapRdbModern.putAll(unmatchedRecordsRdbModern);
        }
        unmatchedRecordsRdb.clear();;
        unmatchedRecordsRdbModern.clear();

        for(String id: mapRdb.keySet())
        {
            DifferentModel differentModel = new DifferentModel();
            diffBuilder.setLength(0);
            diffBuilder.append("NO RECORD FOUND IN RDB_MODERN");

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
            diffBuilder.append("NO RECORD FOUND IN RDB");
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
        Map<String, JsonObject> mapRdb = new HashMap<>();
        Map<String, JsonObject> mapRdbModern = new HashMap<>();

        if (!unmatchedRecordsRdb.isEmpty()) {
            mapRdb.putAll(unmatchedRecordsRdb);
        }


        if (!unmatchedRecordsRdbModern.isEmpty()) {
            mapRdbModern.putAll(unmatchedRecordsRdbModern);
        }

        unmatchedRecordsRdb.clear();;
        unmatchedRecordsRdbModern.clear();


        StringBuilder diffBuilder = new StringBuilder();
        StringBuilder missingColBuilder = new StringBuilder();
        List<DifferentModel> differentModels = new ArrayList<>();

        if (mapRdb.size() < mapRdbModern.size()) {
            for (String id : mapRdb.keySet()) {
                if (mapRdbModern.containsKey(id)) {
                    DifferentModel differentModel = new DifferentModel();
                    JsonObject recordRdb = mapRdb.get(id);
                    JsonObject recordRdbModern = mapRdbModern.get(id);
                    mapRdb.remove(id);
                    mapRdbModern.remove(id);
                    List<String> differList = new ArrayList<>();
                    List<String> missingColList = new ArrayList<>();

                    for (String key : recordRdb.keySet()) {
                        if (ignoreCols.contains(key)) {
                            continue;
                        }

                        // Get value from specific column
                        JsonElement valueRdb = recordRdb.get(key);
                        JsonElement valueRdbModern = recordRdbModern.get(key);
                        recordRdb.remove(key);
                        recordRdbModern.remove(key);

                        if (!valueRdb.equals(valueRdbModern)) {


                            if (valueRdbModern != null) {
                                diffBuilder.setLength(0);
                                diffBuilder.append(key).append(": ")
                                        .append("[RDB_VALUE: ").append(valueRdb).append("], ")
                                        .append("[RDB_MODERN_VALUE: ").append(valueRdbModern).append("]").trimToSize();
                                differList.add(diffBuilder.toString());

                            }
                            else {
                                missingColBuilder.setLength(0);
                                missingColBuilder.append(key).append(" is not exist in RDB_MODERN").trimToSize();
                                missingColList.add(missingColBuilder.toString());

//
//                                diffBuilder.setLength(0);
//                                diffBuilder.append(key).append(": ")
//                                        .append("[RDB_VALUE: ").append(valueRdb).append("], ")
//                                        .append("[RDB_MODERN_VALUE: COLUMN NOT EXIST]").trimToSize();
//                                differList.add(diffBuilder.toString());
                            }

                        }
                    }

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


                }

            }
        }
        else {
            for (String id : mapRdbModern.keySet()) {
                if (mapRdb.containsKey(id)) {
                    DifferentModel differentModel = new DifferentModel();
                    JsonObject recordRdb = mapRdb.get(id);
                    JsonObject recordRdbModern = mapRdbModern.get(id);
                    mapRdb.remove(id);
                    mapRdbModern.remove(id);
                    List<String> differList = new ArrayList<>();
                    List<String> missingColList = new ArrayList<>();

                    for (String key : mapRdbModern.keySet()) {
                        if (ignoreCols.contains(key)) {
                            continue;
                        }

                        // Get value from specific column
                        JsonElement valueRdb = recordRdb.get(key);
                        JsonElement valueRdbModern = recordRdbModern.get(key);
                        recordRdb.remove(key);
                        recordRdbModern.remove(key);

                        if (!valueRdbModern.equals(valueRdb)) {


                            if (valueRdb != null) {
                                diffBuilder.setLength(0);
                                diffBuilder.append(key).append(": ")
                                        .append("[RDB_VALUE: ").append(valueRdb).append("], ")
                                        .append("[RDB_MODERN_VALUE: ").append(valueRdbModern).append("]").trimToSize();
                                differList.add(diffBuilder.toString());

                            }
                            else {
                                missingColBuilder.setLength(0);
                                missingColBuilder.append(key).append(" is not exist in RDB").trimToSize();
                                missingColList.add(missingColBuilder.toString());

//                                diffBuilder.setLength(0);
//                                diffBuilder.append(key).append(": ")
//                                        .append("[RDB_VALUE: COLUMN NOT EXIST")
//                                        .append("[RDB_MODERN_VALUE: ").append(valueRdbModern).append("]").trimToSize();
//                                differList.add(diffBuilder.toString());
                            }

                        }
                    }

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

                }

            }
        }

        if (!mapRdb.isEmpty()) {
            unmatchedRecordsRdb.putAll(mapRdb);
        }

        if(!mapRdbModern.isEmpty()) {
            unmatchedRecordsRdbModern.putAll(mapRdbModern);
        }
        return differentModels;
    }

    /**
     * Max indicate the table that will be used as the subject to be compared against, depending on number of records tables, max can be table from RDB or RDB Modern
     * */
    protected String compareJsonFiles(String fileRdbPath, String fileRdbModernPath, PullerEventModel pullerEventModel, String uniqueIdField,
                                    int index, List<String> ignoreCols, String maxSource)
    {
        Map<String, JsonObject> mapRdb = loadJsonAsMapFromS3(fileRdbPath, uniqueIdField);
        Map<String, JsonObject> mapRdbModern = loadJsonAsMapFromS3(fileRdbModernPath, uniqueIdField);

        if (!unmatchedRecordsRdb.isEmpty()) {
            mapRdb.putAll(unmatchedRecordsRdb);
            unmatchedRecordsRdb.clear();;
        }

        if (!unmatchedRecordsRdbModern.isEmpty()) {
            mapRdbModern.putAll(unmatchedRecordsRdbModern);
            unmatchedRecordsRdbModern.clear();
        }

        StringBuilder diffBuilder = new StringBuilder();
        StringBuilder missingColBuilder = new StringBuilder();
        List<DifferentModel> differentModels = new ArrayList<>();


        // Compare records in both files
        for (String id : mapRdb.keySet()) {
            DifferentModel differentModel = new DifferentModel();
            differentModel.setTable(pullerEventModel.getFileName());
            List<String> differList = new ArrayList<>();
            List<String> missingColList = new ArrayList<>();

            JsonObject recordRdb = mapRdb.get(id);
            JsonObject recordRdbModern = mapRdbModern.get(id);
            var newModernRdbRecord = new HashMap<String, JsonObject>();

            if (recordRdbModern == null) {
                unmatchedRecordsRdb.put(id, recordRdb);  // Retain unmatched records from A in memory
                continue;
            }


            /// HERE: key is column name
            for (String key : recordRdb.keySet()) {
                if (ignoreCols.contains(key)) {
                    continue;
                }

                // Get value from specific column
                JsonElement valueRdb = recordRdb.get(key);
                JsonElement valueRdbModern = recordRdbModern.get(key);
                recordRdbModern.remove(key);

                if (!valueRdb.equals(valueRdbModern)) {


                    if (valueRdbModern != null) {
                        diffBuilder.setLength(0);
                        diffBuilder.append(key).append(": ")
                                .append("[RDB_VALUE: ").append(valueRdb).append("], ")
                                .append("[RDB_MODERN_VALUE: ").append(valueRdbModern).append("]").trimToSize();
                        differList.add(diffBuilder.toString());

                    }
                    else {
//                        diffBuilder.setLength(0);
//                        diffBuilder.append(key).append(": ")
//                                .append("[RDB_VALUE: ").append(valueRdb).append("], ")
//                                .append("[RDB_MODERN_VALUE: COLUMN NOT EXIST]").trimToSize();
//                        differList.add(diffBuilder.toString());
                        missingColBuilder.setLength(0);
                        missingColBuilder.append(key).append(" is not exist in RDB_MODERN").trimToSize();
                        missingColList.add(missingColBuilder.toString());

                    }

                }
            }

            if (!recordRdbModern.isEmpty()) {
                for(String key: recordRdbModern.keySet())
                {
                    if (ignoreCols.contains(key)) {
                        continue;
                    }

//                    JsonElement valueRdbModern = recordRdbModern.get(key);
//                    diffBuilder.setLength(0);
//                    diffBuilder.append(key).append(": ")
//                            .append("[RDB_VALUE: COLUMN NOT EXIST]")
//                            .append("[RDB_MODERN_VALUE: ").append(valueRdbModern).append("]").trimToSize();
//                    differList.add(diffBuilder.toString());

                    missingColBuilder.setLength(0);
                    missingColBuilder.append(key).append(" is not exist in RDB").trimToSize();
                    missingColList.add(missingColBuilder.toString());


                }
            }


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



            differentModel.setKey(id);
            differentModel.setKeyColumn(uniqueIdField);
            differentModel.setDifferentColumnAndValue(diffBuilder.toString().replaceAll("\"", ""));

            if (!differentModel.getDifferentColumnAndValue().equals("[]")) {
                differentModels.add(differentModel);
            } else if (!differentModel.getMissingColumn().equals("[]")) {
                differentModels.add(differentModel);
            }
        }


        // Identify records present only in File B and retain them in memory
        for (String id : mapRdbModern.keySet()) {
            if (!mapRdb.containsKey(id)) {
                unmatchedRecordsRdbModern.put(id, mapRdbModern.get(id));
            }
        }

        var stringValue = gson.toJson(differentModels);
        // Persist the differences to S3
        return s3DataPullerService.uploadDataToS3(
                pullerEventModel.getFirstLayerRdbModernFolderName(),
                pullerEventModel.getSecondLayerFolderName(),
                pullerEventModel.getThirdLayerFolderName(),
                "DIFFERENCE",
                "differences_" + index + ".json", stringValue);
    }
    protected Map<String, JsonObject> loadJsonAsMapFromS3(String fileName, String uniqueIdField) {
        JsonElement jsonElement = s3DataPullerService.readJsonFromS3(fileName);
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
