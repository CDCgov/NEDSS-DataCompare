package gov.cdc.datacomparecron.service.interfaces;
public interface ITokenService {
    /**
     * Gets a valid authentication token
     * @return The authentication token as a string
     */
    String getToken();
}