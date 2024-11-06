package gov.cdc.datacompareprocessor.share;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class StringHelper {
    public static List<String> convertStringToList(String input) {
        if (input == null || input.trim().isEmpty()) {
            return Collections.emptyList();
        }
        return Arrays.asList(input.split("\\s*,\\s*"));
    }
}
