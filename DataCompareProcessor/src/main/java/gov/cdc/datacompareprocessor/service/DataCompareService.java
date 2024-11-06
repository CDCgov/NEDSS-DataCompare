package gov.cdc.datacompareprocessor.service;

import com.google.gson.*;
import com.google.gson.reflect.TypeToken;
import gov.cdc.datacompareprocessor.configuration.TimestampAdapter;
import gov.cdc.datacompareprocessor.kafka.KafkaConsumerService;
import gov.cdc.datacompareprocessor.service.interfaces.IDataCompareService;
import gov.cdc.datacompareprocessor.service.interfaces.IS3DataPullerService;
import gov.cdc.datacompareprocessor.service.model.DifferentModel;
import gov.cdc.datacompareprocessor.service.model.PullerEventModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.lang.reflect.Type;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static gov.cdc.datacompareprocessor.share.StringHelper.convertStringToList;

@Service
public class DataCompareService implements IDataCompareService {
    private static final Logger logger = LoggerFactory.getLogger(DataCompareService.class); //NOSONAR

    private final IS3DataPullerService s3DataPullerService;
    private final Gson gson;

    // Potentially can store these unmatched in S3
    private static final Map<String, JsonObject> unmatchedRecordsRdb = new HashMap<>();
    private static final Map<String, JsonObject> unmatchedRecordsRdbModern = new HashMap<>();


    public DataCompareService(IS3DataPullerService s3DataPullerService) {
        this.s3DataPullerService = s3DataPullerService;
        this.gson = new GsonBuilder()
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampSerializer())
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampDeserializer())
                .serializeNulls()
                .create();
    }

    public void processingData(PullerEventModel pullerEventModel) {
        Map<String, Integer> maxIndexMapper = getMaxIndexWithSource(pullerEventModel);
        Integer maxIndex = maxIndexMapper.get("maxValue");
        String maxIndexSource = maxIndexMapper.get("source") == 1
                ? pullerEventModel.getFirstLayerRdbFolderName()
                : pullerEventModel.getFirstLayerRdbModernFolderName();

        List<DifferentModel> differModels = new ArrayList<>();
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
            differFileNames.add(compareJsonFiles(rdbFile, rdbModernFile, pullerEventModel, pullerEventModel.getKeyColumn(), i,
                    ignoreCols, maxIndexSource));

            for (String differFileName : differFileNames) {
                JsonElement jsonElement = s3DataPullerService.readJsonFromS3(differFileName);
                Type listType = new TypeToken<List<DifferentModel>>() {
                }.getType();
                List<DifferentModel> modelList = gson.fromJson(jsonElement, listType);
                differModels.addAll(modelList);
            }
        }
        var stringValue = gson.toJson(differModels);
        s3DataPullerService.uploadDataToS3(
                pullerEventModel.getFirstLayerRdbModernFolderName(),
                pullerEventModel.getSecondLayerFolderName(),
                pullerEventModel.getThirdLayerFolderName(),
                "differences.json", stringValue);
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
            differentModel.setRdbKey("PRIMARY KEY");
            differentModel.setRdbModernKey("PRIMARY KEY");
            List<String> differList = new ArrayList<>();

            JsonObject recordRdb = mapRdb.get(id);
            JsonObject recordRdbModern = mapRdbModern.get(id);

            if (recordRdbModern == null) {
                unmatchedRecordsRdb.put(id, recordRdb);  // Retain unmatched records from A in memory
                continue;
            }

            for (String key : recordRdb.keySet()) {
                if (ignoreCols.contains(key)) {
                    continue;
                }

                JsonElement valueRdb = recordRdb.get(key);
                JsonElement valueRdbModern = recordRdbModern.get(key);

                if (!valueRdb.equals(valueRdbModern)) {
                    diffBuilder.setLength(0);
                    diffBuilder.append("\"").append(key).append("\" : {\n")
                            .append("    \"RDB_VALUE\": ").append(valueRdb.toString()).append(",\n")
                            .append("    \"RDB_MODERN_VALUE\": ").append(valueRdbModern.toString()).append("\n")
                            .append("}");
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

            differentModel.setDifferentColumnAndValue(diffBuilder.toString());

            differentModels.add(differentModel);
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
