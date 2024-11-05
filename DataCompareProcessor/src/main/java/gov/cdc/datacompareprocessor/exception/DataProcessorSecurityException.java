package gov.cdc.datacompareprocessor.exception;

import org.springframework.security.core.AuthenticationException;

public class DataProcessorSecurityException extends AuthenticationException {
    public DataProcessorSecurityException(String message) {
        super(message);
    }
}