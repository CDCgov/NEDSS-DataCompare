package gov.cdc.datacompareprocessor.service.interfaces;

import com.google.gson.JsonElement;

public interface IStorageDataPullerService {
    JsonElement readJsonFromStorage(String fileName);
    String uploadDataToStorage(String folder1, String folder2, String folder3, String folder4, String fileName, String data);
}
