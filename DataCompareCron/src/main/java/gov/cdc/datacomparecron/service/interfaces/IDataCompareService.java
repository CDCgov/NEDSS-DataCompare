package gov.cdc.datacomparecron.service.interfaces;

/**
 * Interface for data comparison operations
 */
public interface IDataCompareService {
    /**
     * Triggers data comparison with optional immediate execution
     * @param runNow If true, executes comparison immediately
     */
    void compareData(boolean runNow);
}