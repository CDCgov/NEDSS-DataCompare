package service;

import gov.cdc.datacompareprocessor.kafka.KafkaProducerService;
import gov.cdc.datacompareprocessor.repository.rdb.DataCompareLogRepository;
import gov.cdc.datacompareprocessor.repository.rdb.model.DataCompareLog;
import gov.cdc.datacompareprocessor.service.DataCompareService;
import gov.cdc.datacompareprocessor.service.interfaces.IS3DataPullerService;
import gov.cdc.datacompareprocessor.service.model.PullerEventModel;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Optional;

import static org.mockito.Mockito.when;

class DataCompareServiceTest {
    @Mock
    private IS3DataPullerService dataPullerService;

    @Mock
    private DataCompareLogRepository dataCompareLogRepository;

    @Mock
    private KafkaProducerService kafkaProducerService;


    @InjectMocks
    private DataCompareService dataCompareService;


    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }


    @Test
    void processingDataTest_RdbMax() {
        var pull = setupPullerModel(200, 100);
        var logRdb = setupLog(1L);
        var logModern = setupLog(2L);
        when(dataCompareLogRepository.findById(1L)).thenReturn(Optional.of(logRdb));
        when(dataCompareLogRepository.findById(2L)).thenReturn(Optional.of(logRdb));

    }

    private PullerEventModel setupPullerModel(int rdbMax, int modernMax) {
        PullerEventModel pullerEventModel = new PullerEventModel();
        pullerEventModel.setFirstLayerRdbFolderName("RDB");
        pullerEventModel.setFirstLayerRdbModernFolderName("RDB_MODERN");
        pullerEventModel.setSecondLayerFolderName("DATABASE");
        pullerEventModel.setThirdLayerFolderName("TIMESTAMP");
        pullerEventModel.setFileName("TABLE");
        pullerEventModel.setRdbMaxIndex(rdbMax);
        pullerEventModel.setRdbModernMaxIndex(modernMax);
        pullerEventModel.setKeyColumn("KEY");
        pullerEventModel.setIgnoreColumns("KEY, TEST");
        pullerEventModel.setLogIdRdb(1L);
        pullerEventModel.setLogIdRdbModern(2L);
        return pullerEventModel;
    }

    private DataCompareLog setupLog(Long id) {
        DataCompareLog log = new DataCompareLog();
        log.setDcLogId(id);
        return log;
    }
}
