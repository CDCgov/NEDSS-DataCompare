package gov.cdc.datacomparecron.service;

import gov.cdc.datacomparecron.service.interfaces.IDataCompareApiService;
import gov.cdc.datacomparecron.service.interfaces.ITokenService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

class DataCompareCronServiceTest {

    @Mock
    private IDataCompareApiService apiService;

    @InjectMocks
    private DataCompareCronService cronService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        ReflectionTestUtils.setField(cronService, "defaultRunNow", false);
    }

    @Test
    void testScheduleDataCompare() {
        cronService.scheduleDataCompare();
        verify(apiService, times(1)).compareData(false, false);
    }

    @Test
    void testScheduleDataCompareWithRunNow() {
        cronService.scheduleDataCompare(true, false);
        verify(apiService, times(1)).compareData(true, false);
    }
}

