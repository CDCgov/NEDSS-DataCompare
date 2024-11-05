package gov.cdc.datacompareapis.shared;

public class NumberHelper {
    public static boolean isInteger(String value) {
        if (value == null) {
            return false;
        }
        try {
            Integer.parseInt(value);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }
}
