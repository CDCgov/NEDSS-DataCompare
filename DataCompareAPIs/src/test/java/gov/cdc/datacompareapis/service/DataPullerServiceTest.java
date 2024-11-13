package gov.cdc.datacompareapis.service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import gov.cdc.datacompareapis.configuration.TimestampAdapter;
import gov.cdc.datacompareapis.exception.DataCompareException;
import gov.cdc.datacompareapis.kafka.KafkaProducerService;
import gov.cdc.datacompareapis.repository.rdb.DataCompareConfigRepository;
import gov.cdc.datacompareapis.repository.rdb.DataCompareLogRepository;
import gov.cdc.datacompareapis.repository.rdb.model.DataCompareConfig;
import gov.cdc.datacompareapis.repository.rdb.model.DataCompareLog;
import gov.cdc.datacompareapis.service.interfaces.IS3DataService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.jdbc.core.JdbcTemplate;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

class DataPullerServiceTest {

    @Mock
    private DataCompareConfigRepository dataCompareConfigRepository;

    @Mock
    private DataCompareLogRepository dataCompareLogRepository;

    @Mock
    private KafkaProducerService kafkaProducerService;

    @Mock
    private JdbcTemplate rdbJdbcTemplate;

    @Mock
    private JdbcTemplate rdbModernJdbcTemplate;

    @Mock
    private IS3DataService s3DataService;

    @InjectMocks
    private DataPullerService dataPullerService;

    private Gson gson;
    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        gson = new GsonBuilder()
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampSerializer())
                .registerTypeAdapter(Timestamp.class, TimestampAdapter.getTimestampDeserializer())
                .serializeNulls()
                .create();
    }

    @Test
    void pullingDataTestRunNow1() {
        int pullLimit = 100;
        boolean runNowMode = true;
        var configs = getDataConfig(true, runNowMode);
        when(dataCompareConfigRepository.findAll()).thenReturn(configs);

        when(rdbJdbcTemplate.queryForObject(configs.get(0).getQueryCount(), Integer.class)).thenReturn(100);
        when(rdbModernJdbcTemplate.queryForObject(configs.get(0).getQueryCount(), Integer.class)).thenReturn(100);

        var jdbcData = getJdbcData();
        when(rdbJdbcTemplate.queryForList(any())).thenReturn(jdbcData);
        when(rdbModernJdbcTemplate.queryForList(any())).thenReturn(jdbcData);

        var log = new DataCompareLog();
        when(dataCompareLogRepository.save(any())).thenReturn(log);

        dataPullerService.pullingData(pullLimit, runNowMode);

        verify(kafkaProducerService, times(1)).sendEventToProcessor(anyString(), anyString());

    }

    @Test
    void pullingDataTestRunNow_Count_Is_Null() {
        int pullLimit = 100;
        boolean runNowMode = true;
        var configs = getDataConfig(true, runNowMode);
        when(dataCompareConfigRepository.findAll()).thenReturn(configs);

        when(rdbJdbcTemplate.queryForObject(configs.get(0).getQueryCount(), Integer.class)).thenReturn(null);
        when(rdbModernJdbcTemplate.queryForObject(configs.get(0).getQueryCount(), Integer.class)).thenReturn(null);

        dataPullerService.pullingData(pullLimit, runNowMode);

        verify(kafkaProducerService, times(0)).sendEventToProcessor(anyString(), anyString());

    }


    @Test
    void pullingDataTestRunNow_Error_Rdb() {
        int pullLimit = 100;
        boolean runNowMode = true;
        var configs = getDataConfig(true, runNowMode);
        when(dataCompareConfigRepository.findAll()).thenReturn(configs);

        when(rdbJdbcTemplate.queryForObject(configs.get(0).getQueryCount(), Integer.class)).thenReturn(100);
        when(rdbModernJdbcTemplate.queryForObject(configs.get(0).getQueryCount(), Integer.class)).thenReturn(100);

        when(rdbJdbcTemplate.queryForList(any())).thenThrow(new RuntimeException("Error message"));


        var log = new DataCompareLog();
        when(dataCompareLogRepository.save(any())).thenReturn(log);

        dataPullerService.pullingData(pullLimit, runNowMode);

        verify(kafkaProducerService, times(0)).sendEventToProcessor(anyString(), anyString());

    }

    @Test
    void pullingDataTestRunNow_Error_RdbModern() {
        int pullLimit = 100;
        boolean runNowMode = true;
        var configs = getDataConfig(true, runNowMode);
        when(dataCompareConfigRepository.findAll()).thenReturn(configs);

        when(rdbJdbcTemplate.queryForObject(configs.get(0).getQueryCount(), Integer.class)).thenReturn(100);
        when(rdbModernJdbcTemplate.queryForObject(configs.get(0).getQueryCount(), Integer.class)).thenReturn(100);

        var jdbcData = getJdbcData();
        when(rdbJdbcTemplate.queryForList(any())).thenReturn(jdbcData);
        when(rdbModernJdbcTemplate.queryForList(any())).thenThrow(new RuntimeException("Error message"));

        var log = new DataCompareLog();
        when(dataCompareLogRepository.save(any())).thenReturn(log);

        dataPullerService.pullingData(pullLimit, runNowMode);

        verify(kafkaProducerService, times(0)).sendEventToProcessor(anyString(), anyString());

    }

    @Test
    void testExecuteQueryForData_DataNotSupported() {
        String query = "Query";
        String source = "TEST";

        assertThrows(DataCompareException.class, () ->
                dataPullerService.executeQueryForData(query, source));
    }

    List<DataCompareConfig> getDataConfig(boolean compare, boolean runNow) {
        var configs = new ArrayList<DataCompareConfig>();
        var config = new DataCompareConfig();
        config.setConfigId(1L);
        config.setTableName("PATIENT");
        config.setSourceDb("RDB");
        config.setTargetDb("RDB_MODERN");
        config.setQuery("QUERY");
        config.setQueryCount("QUERY_COUNT");
        config.setKeyColumns("TEST");
        config.setIgnoreColumns("TEST, TEST");
        config.setCompare(compare);
        config.setRunNow(runNow);
        configs.add(config);
        return configs;
    }

    List<Map<String, Object>> getJdbcData() {

        List<Map<String, Object>> data = new ArrayList<>();
        Map<String, Object> map = new HashMap<>();
        map.put("CONDITION", "RDB");
        map.put("SELECT * FROM CONDITION;", null);
        map.put("2024-08-19 15:19:49.4830000", "2024-08-19 15:19:49.4830000");
        data.add(map);

        return data;
    }
}
