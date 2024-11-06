package gov.cdc.datacompareprocessor.service.interfaces;

import com.google.gson.JsonElement;

public interface IS3DataPullerService {
    JsonElement readJsonFromS3(String fileName);
    String uploadDataToS3(String folder1, String folder2, String folder3, String fileName, String data);
}
