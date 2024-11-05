package gov.cdc.datacompareapis.exception;

import org.springframework.security.core.AuthenticationException;

public class DataCompareSecurityException extends AuthenticationException {
    public DataCompareSecurityException(String message) {
        super(message);
    }
}