package gov.cdc.datacomparecron.service.interfaces;

/**
 * Interface for data comparison operations
 */
public interface IDataCompareCronService {
    /**
     * Triggers data comparison with optional immediate execution
     * @param runNow If true, executes comparison immediately
     */
    void scheduleDataCompare(boolean runNow, boolean autoApply);
}