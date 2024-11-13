package gov.cdc.datacompareapis.controller;

import com.google.gson.Gson;
import gov.cdc.datacompareapis.exception.DataCompareException;
import gov.cdc.datacompareapis.service.interfaces.IDataPullerService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;

class DataCompareControllerTest {
    @Mock
    private IDataPullerService dataPullerService;
    @InjectMocks
    private DataCompareController dataCompareController;
    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void dataSyncTotalRecords_Test() throws DataCompareException {
        String batchLimit = "1000";
        boolean runNowMode = false;
        ResponseEntity<String> response = dataCompareController.dataSyncTotalRecords(batchLimit, runNowMode);
        assertEquals(HttpStatus.OK, response.getStatusCode());
    }

    @Test
    void dataSyncTotalRecords_Error()  {
        String batchLimit = "AAA";
        boolean runNowMode = false;

        assertThrows(DataCompareException.class, () ->
                dataCompareController.dataSyncTotalRecords(batchLimit, runNowMode)
        );
    }


    @Test
    void healthCheck()  {
        ResponseEntity<String> response = dataCompareController.decodeAndDecompress();
        assertEquals(HttpStatus.OK, response.getStatusCode());
    }

}
