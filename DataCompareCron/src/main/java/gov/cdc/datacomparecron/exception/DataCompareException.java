package gov.cdc.datacomparecron.exception;

public class DataCompareException extends RuntimeException {
    public DataCompareException(String message) {
        super(message);
    }

    public DataCompareException(String message, Throwable cause) {
        super(message, cause);
    }
}