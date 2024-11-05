package gov.cdc.datacompareapis.service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import gov.cdc.datacompareapis.configuration.TimestampAdapter;
import gov.cdc.datacompareapis.exception.DataCompareException;
import gov.cdc.datacompareapis.repository.rdb.DataCompareConfigRepository;
import gov.cdc.datacompareapis.repository.rdb.DataCompareLogRepository;
import gov.cdc.datacompareapis.repository.rdb.model.DataCompareConfig;
import gov.cdc.datacompareapis.repository.rdb.model.DataCompareLog;
import gov.cdc.datacompareapis.service.interfaces.IDataPullerService;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.util.List;

@Service
public class DataPullerService implements IDataPullerService {
    private final DataCompareConfigRepository dataCompareConfigRepository;
    private final DataCompareLogRepository dataCompareLogRepository;
    private final Gson gson;
    private final JdbcTemplate rdbJdbcTemplate;
    private final JdbcTemplate rdbModernJdbcTemplate;

    public DataPullerService(DataCompareConfigRepository dataCompareConfigRepository,
                             DataCompareLogRepository dataCompareLogRepository,
                             Gson gson,
                             @Qualifier("rdbJdbcTemplate") JdbcTemplate rdbJdbcTemplate,
                             @Qualifier("rdbModernJdbcTemplate") JdbcTemplate rdbModernJdbcTemplate) {
        this.dataCompareConfigRepository = dataCompareConfigRepository;
        this.dataCompareLogRepository = dataCompareLogRepository;
        this.rdbJdbcTemplate = rdbJdbcTemplate;
        this.rdbModernJdbcTemplate = rdbModernJdbcTemplate;
        this.gson = new GsonBuilder()
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampSerializer())
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampDeserializer())
                .serializeNulls()
                .create();
    }

    public void pullingDatas() throws DataCompareException {
        List<DataCompareConfig>  configs = getDataConfig();
        for(DataCompareConfig config : configs) {

        }
    }


    protected void pullingTableByPair(DataCompareConfig config) {

    }



    private List<DataCompareConfig> getDataConfig() throws DataCompareException {
        return dataCompareConfigRepository.findAll();
    }


}
