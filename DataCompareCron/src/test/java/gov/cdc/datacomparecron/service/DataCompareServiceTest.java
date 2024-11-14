package gov.cdc.datacomparecron.service;

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

class DataCompareServiceTest {

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private ITokenService tokenService;

    @InjectMocks
    private DataCompareService dataCompareService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        ReflectionTestUtils.setField(dataCompareService, "compareEndpoint", "http://example.com/compare");
    }

    @Test
    void testCompareData_Success() {

        String token = "testToken";
        when(tokenService.getToken()).thenReturn(token);

        HttpHeaders expectedHeaders = new HttpHeaders();
        expectedHeaders.add("Authorization", "Bearer " + token);
        HttpEntity<String> expectedEntity = new HttpEntity<>(expectedHeaders);

        when(restTemplate.exchange(
                eq("http://example.com/compare?runNow=false"),
                eq(HttpMethod.GET),
                eq(expectedEntity),
                eq(String.class)
        )).thenReturn(ResponseEntity.ok("Success"));

        dataCompareService.compareData(false);


        verify(tokenService, times(1)).getToken();
        verify(restTemplate, times(1)).exchange(
                eq("http://example.com/compare?runNow=false"),
                eq(HttpMethod.GET),
                eq(expectedEntity),
                eq(String.class)
        );
    }

    @Test
    void testCompareData_WithRunNowTrue() {

        String token = "testToken";
        when(tokenService.getToken()).thenReturn(token);

        HttpHeaders expectedHeaders = new HttpHeaders();
        expectedHeaders.add("Authorization", "Bearer " + token);
        HttpEntity<String> expectedEntity = new HttpEntity<>(expectedHeaders);

        when(restTemplate.exchange(
                eq("http://example.com/compare?runNow=true"),
                eq(HttpMethod.GET),
                eq(expectedEntity),
                eq(String.class)
        )).thenReturn(ResponseEntity.ok("Success"));


        dataCompareService.compareData(true);

        verify(tokenService, times(1)).getToken();
        verify(restTemplate, times(1)).exchange(
                eq("http://example.com/compare?runNow=true"),
                eq(HttpMethod.GET),
                eq(expectedEntity),
                eq(String.class)
        );
    }

    @Test
    void testCompareData_WhenTokenServiceFails() {
        when(tokenService.getToken()).thenThrow(new RuntimeException("Token Error"));

        Exception exception = assertThrows(RuntimeException.class, () ->
                dataCompareService.compareData(false)
        );
        assertEquals("Failed to complete data comparison", exception.getMessage());
        verify(tokenService, times(1)).getToken();
        verify(restTemplate, never()).exchange(
                any(String.class),
                any(HttpMethod.class),
                any(HttpEntity.class),
                eq(String.class)
        );
    }

    @Test
    void testCompareData_WhenRestTemplateFails() {

        String token = "testToken";
        when(tokenService.getToken()).thenReturn(token);

        HttpHeaders expectedHeaders = new HttpHeaders();
        expectedHeaders.add("Authorization", "Bearer " + token);
        HttpEntity<String> expectedEntity = new HttpEntity<>(expectedHeaders);

        when(restTemplate.exchange(
                eq("http://example.com/compare?runNow=false"),
                eq(HttpMethod.GET),
                eq(expectedEntity),
                eq(String.class)
        )).thenThrow(new RuntimeException("API Error"));

        Exception exception = assertThrows(RuntimeException.class, () ->
                dataCompareService.compareData(false)
        );
        assertEquals("Failed to complete data comparison", exception.getMessage());
        verify(tokenService, times(1)).getToken();
        verify(restTemplate, times(1)).exchange(
                eq("http://example.com/compare?runNow=false"),
                eq(HttpMethod.GET),
                eq(expectedEntity),
                eq(String.class)
        );
    }

    @Test
    void testScheduleDataCompare() {

        String token = "testToken";
        when(tokenService.getToken()).thenReturn(token);

        HttpHeaders expectedHeaders = new HttpHeaders();
        expectedHeaders.add("Authorization", "Bearer " + token);
        HttpEntity<String> expectedEntity = new HttpEntity<>(expectedHeaders);

        when(restTemplate.exchange(
                any(String.class),
                eq(HttpMethod.GET),
                any(HttpEntity.class),
                eq(String.class)
        )).thenReturn(ResponseEntity.ok("Success"));


        dataCompareService.scheduleDataCompare();


        verify(tokenService, times(1)).getToken();
        verify(restTemplate, times(1)).exchange(
                eq("http://example.com/compare?runNow=false"),
                eq(HttpMethod.GET),
                eq(expectedEntity),
                eq(String.class)
        );
    }
}