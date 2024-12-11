package gov.cdc.datacomparecron.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.*;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class DataCompareApiServiceTest {
    @Mock
    private RestTemplate restTemplate;

    @Mock
    private TokenService tokenService;

    @InjectMocks
    private DataCompareApiService apiService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        ReflectionTestUtils.setField(apiService, "compareEndpoint", "http://example.com/compare");
    }

    @Test
    void testCompareData_Success() {
        String token = "testToken";
        when(tokenService.getToken()).thenReturn(token);

        HttpHeaders expectedHeaders = new HttpHeaders();
        expectedHeaders.add("Authorization", "Bearer " + token);
        expectedHeaders.add("runNowMode", "false");
        expectedHeaders.add("autoApply", "false");

        HttpEntity<String> expectedEntity = new HttpEntity<>(expectedHeaders);

        when(restTemplate.exchange(
                eq("http://example.com/compare"),
                eq(HttpMethod.GET),
                eq(expectedEntity),
                eq(String.class)
        )).thenReturn(ResponseEntity.ok("Success"));

        apiService.compareData(false, false);

        verify(tokenService, times(1)).getToken();
        verify(restTemplate, times(1)).exchange(
                eq("http://example.com/compare"),
                eq(HttpMethod.GET),
                eq(expectedEntity),
                eq(String.class)
        );
    }

    @Test
    void testCompareData_WhenTokenServiceFails() {
        when(tokenService.getToken()).thenThrow(new RuntimeException("Token Error"));

        Exception exception = assertThrows(RuntimeException.class, () ->
                apiService.compareData(false, false)
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
        expectedHeaders.add("runNowMode", "false");
        expectedHeaders.add("autoApply", "false");

        HttpEntity<String> expectedEntity = new HttpEntity<>(expectedHeaders);

        when(restTemplate.exchange(
                eq("http://example.com/compare"),
                eq(HttpMethod.GET),
                eq(expectedEntity),
                eq(String.class)
        )).thenThrow(new RuntimeException("API Error"));

        Exception exception = assertThrows(RuntimeException.class, () ->
                apiService.compareData(false, false)
        );
        assertEquals("Failed to complete data comparison", exception.getMessage());
    }
}