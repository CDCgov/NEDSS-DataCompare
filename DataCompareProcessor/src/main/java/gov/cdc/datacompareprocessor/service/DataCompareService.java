package gov.cdc.datacompareprocessor.service;

import com.google.gson.*;
import com.google.gson.reflect.TypeToken;
import gov.cdc.datacompareprocessor.configuration.TimestampAdapter;
import gov.cdc.datacompareprocessor.service.interfaces.IDataCompareService;
import gov.cdc.datacompareprocessor.service.interfaces.IS3DataPullerService;
import gov.cdc.datacompareprocessor.service.model.PullerEventModel;
import org.springframework.stereotype.Service;

import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.lang.reflect.Type;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.Map;

@Service
public class DataCompareService implements IDataCompareService {

    private final IS3DataPullerService s3DataPullerService;
    private final Gson gson;
    private static final Map<String, JsonObject> unmatchedRecordsA = new HashMap<>();
    private static final Map<String, JsonObject> unmatchedRecordsB = new HashMap<>();


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

        for (int i = 0; i < maxIndex+1; i++) {
            String rdbFile = pullerEventModel.getFirstLayerRdbFolderName()
                    + "/" + pullerEventModel.getSecondLayerFolderName()
                    + "/" + pullerEventModel.getThirdLayerFolderName()
                    + "/" + pullerEventModel.getFileName() + "_" + i + ".json";
            String rdbModernFile  = pullerEventModel.getFirstLayerRdbModernFolderName()
                    + "/" + pullerEventModel.getSecondLayerFolderName()
                    + "/" + pullerEventModel.getThirdLayerFolderName()
                    + "/" + pullerEventModel.getFileName() + "_" + i + ".json";
            compareJsonFiles(rdbFile, rdbModernFile, pullerEventModel, "PATIENT_KEY", i);

        }
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

    protected void compareJsonFiles(String fileAPath, String fileBPath, PullerEventModel pullerEventModel, String uniqueIdField,
                                    int index)
    {
        Map<String, JsonObject> mapA = loadJsonAsMapFromS3(fileAPath, uniqueIdField);
        Map<String, JsonObject> mapB = loadJsonAsMapFromS3(fileBPath, uniqueIdField);

        StringBuilder diffBuilder = new StringBuilder("Differences between records with matching IDs:\n");

        // Compare records in both files
        for (String id : mapA.keySet()) {
            JsonObject recordA = mapA.get(id);
            JsonObject recordB = mapB.get(id);

            if (recordB == null) {
                unmatchedRecordsA.put(id, recordA);  // Retain unmatched records from A in memory
                continue;
            }

            boolean hasDifference = false;
            for (String key : recordA.keySet()) {
                JsonElement valueA = recordA.get(key);
                JsonElement valueB = recordB.get(key);

                if (!valueA.equals(valueB)) {
                    if (!hasDifference) {
                        diffBuilder.append("Differences for ID ").append(id).append(":\n");
                        hasDifference = true;
                    }
                    diffBuilder.append("  Field '").append(key).append("': File A = ").append(valueA).append(", File B = ").append(valueB).append("\n");
                }
            }
        }

        // Identify records present only in File B and retain them in memory
        for (String id : mapB.keySet()) {
            if (!mapA.containsKey(id)) {
                unmatchedRecordsB.put(id, mapB.get(id));
            }
        }

        // Persist the differences to S3
        s3DataPullerService.uploadDataToS3(
                pullerEventModel.getFirstLayerRdbModernFolderName(),
                pullerEventModel.getThirdLayerFolderName(), "differences_" + index + ".json", diffBuilder.toString());
    }
    protected Map<String, JsonObject> loadJsonAsMapFromS3(String fileName, String uniqueIdField) {
        JsonElement jsonElement = s3DataPullerService.readJsonFromS3(fileName);

        // Convert JsonArray into a map using the unique identifier field
        Map<String, JsonObject> recordMap = new HashMap<>();
        for (JsonElement element : jsonElement.getAsJsonArray()) {
            JsonObject jsonObject = element.getAsJsonObject();
            String id = jsonObject.get(uniqueIdField).getAsString();
            recordMap.put(id, jsonObject);
        }
        return recordMap;
    }
}
