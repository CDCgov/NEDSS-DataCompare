package gov.cdc.datacompareprocessor.service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import gov.cdc.datacompareprocessor.configuration.TimestampAdapter;
import gov.cdc.datacompareprocessor.kafka.KafkaProducerService;
import gov.cdc.datacompareprocessor.repository.rdb.DataCompareLogRepository;
import gov.cdc.datacompareprocessor.repository.rdb.model.DataCompareLog;
import gov.cdc.datacompareprocessor.service.interfaces.IDataCompareService;
import gov.cdc.datacompareprocessor.service.interfaces.IS3DataPullerService;
import gov.cdc.datacompareprocessor.service.model.DifferentModel;
import gov.cdc.datacompareprocessor.service.model.PullerEventModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.lang.reflect.Type;
import java.sql.Timestamp;
import java.util.*;

import static gov.cdc.datacompareprocessor.share.StackTraceUtil.getStackTraceAsString;
import static gov.cdc.datacompareprocessor.share.StringHelper.convertStringToList;
import static gov.cdc.datacompareprocessor.share.TimestampHandler.getCurrentTimeStamp;

@Service
public class DataCompareService implements IDataCompareService {
    private static final Logger logger = LoggerFactory.getLogger(DataCompareService.class); //NOSONAR

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
//                    differModels.addAll(
//                            modelList.stream().filter(model -> !"[]".equals(model.differentColumnAndValue)).toList()
//                    );
                }
            }


            var stringValue = gson.toJson(differModels);
            s3DataPullerService.uploadDataToS3(
                    pullerEventModel.getFirstLayerRdbModernFolderName(),
                    pullerEventModel.getSecondLayerFolderName(),
                    pullerEventModel.getThirdLayerFolderName(),
                    "DIFFERENCE",
                    "differences.json", stringValue);

            // TODO: create object with info to pull from S3 and invoke the event
            kafkaProducerService.sendEventToProcessor("GSON Object GOES HERE", emailTopicName);
            logRdb.setStatus("Complete");
            logRdbModern.setStatus("Complete");
        }
        catch (Exception e)
        {
            logger.error("ERROR: {}", e.getMessage());
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

        dataCompareLogRepository.save(logRdb);
        dataCompareLogRepository.save(logRdbModern);

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
        List<DifferentModel> differentModels = new ArrayList<>();
        // Compare records in both files
        for (String id : mapRdb.keySet()) {
            DifferentModel differentModel = new DifferentModel();
            differentModel.setTable(pullerEventModel.getFileName());
            List<String> differList = new ArrayList<>();

            JsonObject recordRdb = mapRdb.get(id);
            JsonObject recordRdbModern = mapRdbModern.get(id);

            if (recordRdbModern == null) {
                unmatchedRecordsRdb.put(id, recordRdb);  // Retain unmatched records from A in memory
                continue;
            }


            if (id.equals("10117008")) {
                logger.info("TEST");
            }
            for (String key : recordRdb.keySet()) {
                if (ignoreCols.contains(key)) {
                    continue;
                }

                JsonElement valueRdb = recordRdb.get(key);
                JsonElement valueRdbModern = recordRdbModern.get(key);

                if (!valueRdb.equals(valueRdbModern)) {
                    diffBuilder.setLength(0);
                    diffBuilder.append(key).append(": ")
                            .append("[RDB_VALUE: ").append(valueRdb).append("], ")
                            .append("[RDB_MODERN_VALUE: ").append(valueRdbModern).append("]").trimToSize();
                    differList.add(diffBuilder.toString());
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

            differentModel.setKey(id);
            differentModel.setKeyColumn(uniqueIdField);
            differentModel.setDifferentColumnAndValue(diffBuilder.toString().replaceAll("\"", ""));

            if (!differentModel.getDifferentColumnAndValue().equals("[]")) {
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
            // Convert JsonArray into a map using the unique identifier field
            for (JsonElement element : jsonElement.getAsJsonArray()) {
                JsonObject jsonObject = element.getAsJsonObject();
                String id = jsonObject.get(uniqueIdField).getAsString();
                recordMap.put(id, jsonObject);
            }
        } catch (Exception e) {
            logger.error(e.getMessage());
        }

        return recordMap;
    }
}
