package gov.cdc.datacompareapis.configuration;

import com.google.gson.JsonDeserializer;
import com.google.gson.JsonParseException;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
@SuppressWarnings("java:S1118")
public class TimestampAdapter {

    @SuppressWarnings("java:S2885")
    private static final SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");

    // Serializer: Convert Timestamp to JSON
    public static JsonSerializer<Timestamp> getTimestampSerializer() {
        return (src, typeOfSrc, context) -> {
            if (src == null) {
                return null;
            }
            try {
                String formattedDate = dateFormat.format(src);
                return new JsonPrimitive(formattedDate);
            } catch (Exception e) {                
                return new JsonPrimitive(src.toString());
            }
        };
    }

    // Deserializer: Convert JSON to Timestamp
    public static JsonDeserializer<Timestamp> getTimestampDeserializer() {
        return (json, typeOfT, context) -> {
            try {
                return new Timestamp(dateFormat.parse(json.getAsJsonPrimitive().getAsString()).getTime());
            } catch (Exception e) {
                throw new JsonParseException(e);
            }
        };
    }
}