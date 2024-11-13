package gov.cdc.datacompareapis.service;

import gov.cdc.datacompareapis.exception.DataCompareException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;

import java.sql.Timestamp;

import static org.junit.jupiter.api.Assertions.*;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.mockito.Mockito.times;

public class S3DataServiceTest {
    @Mock
    private S3Client s3Client;
    private S3DataService s3DataService;


    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testPersistToS3MultiPart_Success()  {
        s3DataService = new S3DataService(s3Client);  // Use the constructor for testing

        // Mock the necessary AWS S3 responses
        String uploadId = "testUploadId";
        String fileName = "testFile";
        Timestamp timestamp = new Timestamp(System.currentTimeMillis());
        String records = "[{\"test\": \"data\"}]";

        // Mock the S3 multipart upload initiation
        when(s3Client.createMultipartUpload(any(CreateMultipartUploadRequest.class)))
                .thenReturn(CreateMultipartUploadResponse.builder().uploadId(uploadId).build());

        // Mock the upload of parts
        when(s3Client.uploadPart(any(UploadPartRequest.class), any(software.amazon.awssdk.core.sync.RequestBody.class)))
                .thenReturn(UploadPartResponse.builder().eTag("testETag").build());

        // Mock the multipart upload completion
        when(s3Client.completeMultipartUpload(any(CompleteMultipartUploadRequest.class)))
                .thenReturn(CompleteMultipartUploadResponse.builder().build());

        // Call the method to test
        String result = s3DataService.persistToS3MultiPart("", records, fileName, timestamp, 1);

        // Verify the interactions with the S3 client
        verify(s3Client, times(1)).createMultipartUpload(any(CreateMultipartUploadRequest.class));
        verify(s3Client, atLeastOnce()).uploadPart(any(UploadPartRequest.class), any(software.amazon.awssdk.core.sync.RequestBody.class));
        verify(s3Client, times(1)).completeMultipartUpload(any(CompleteMultipartUploadRequest.class));

        // Assert the expected result
        assertEquals("SUCCESS", result);
    }

    @Test
    void testPersistToS3MultiPart_EmptyData()  {
        s3DataService = new S3DataService(s3Client);  // Use the constructor for testing

        // Test with empty records
        var res = s3DataService.persistToS3MultiPart("", "", "testFile", new Timestamp(System.currentTimeMillis()), 1);

        // Verify exception message
        assertEquals("No data to persist for table testFile", res);
    }

    @Test
    void testPersistToS3MultiPart_AWSUploadFailure()  {
        s3DataService = new S3DataService(s3Client);  // Use the constructor for testing

        // Mock the necessary AWS S3 responses
        String uploadId = "testUploadId";
        String fileName = "testFile";
        Timestamp timestamp = new Timestamp(System.currentTimeMillis());
        String records = "[{\"test\": \"data\"}]";

        // Mock initiate multipart upload
        when(s3Client.createMultipartUpload(any(CreateMultipartUploadRequest.class)))
                .thenReturn(CreateMultipartUploadResponse.builder().uploadId(uploadId).build());

        // Mock an exception during upload part
        when(s3Client.uploadPart(any(UploadPartRequest.class), any(software.amazon.awssdk.core.sync.RequestBody.class)))
                .thenThrow(S3Exception.builder().message("S3 Upload Failure").build());

        // Test the method
        String result = s3DataService.persistToS3MultiPart("", records, fileName, timestamp, 1);

        // Verify that the error message is logged and returned
        assertEquals("S3 Upload Failure", result);
    }

    @Test
    void testPersistToS3MultiPart_InvalidUploadId()  {
        s3DataService = new S3DataService(s3Client);  // Use the constructor for testing

        // Test scenario where uploadId is invalid or null
        String fileName = "testFile";
        Timestamp timestamp = new Timestamp(System.currentTimeMillis());
        String records = "[{\"test\": \"data\"}]";

        // Mock invalid upload ID response
        when(s3Client.createMultipartUpload(any(CreateMultipartUploadRequest.class)))
                .thenReturn(CreateMultipartUploadResponse.builder().uploadId(null).build());

        // Call the method and verify it doesn't crash
        String result = s3DataService.persistToS3MultiPart("", records, fileName, timestamp, 1);

        // Check if the process completes, but no upload is performed
        assertNotNull(result);
    }

    @Test
    void testPersistToS3MultiPart_InitialLoad()  {
        s3DataService = new S3DataService(s3Client);  // Use the constructor for testing

        // Mock the necessary AWS S3 responses
        String uploadId = "testUploadId";
        String fileName = "testFile";
        Timestamp timestamp = new Timestamp(System.currentTimeMillis());
        String records = "[{\"test\": \"data\"}]";

        // Mock initiate multipart upload
        when(s3Client.createMultipartUpload(any(CreateMultipartUploadRequest.class)))
                .thenReturn(CreateMultipartUploadResponse.builder().uploadId(uploadId).build());

        // Mock the upload of parts
        when(s3Client.uploadPart(any(UploadPartRequest.class), any(software.amazon.awssdk.core.sync.RequestBody.class)))
                .thenReturn(UploadPartResponse.builder().eTag("testETag").build());

        // Mock the multipart upload completion
        when(s3Client.completeMultipartUpload(any(CompleteMultipartUploadRequest.class)))
                .thenReturn(CompleteMultipartUploadResponse.builder().build());

        // Call the method with initialLoad = true
        String result = s3DataService.persistToS3MultiPart("", records, fileName, timestamp, 1);

        // Verify the interactions with the S3 client
        verify(s3Client, times(1)).createMultipartUpload(any(CreateMultipartUploadRequest.class));
        verify(s3Client, atLeastOnce()).uploadPart(any(UploadPartRequest.class), any(software.amazon.awssdk.core.sync.RequestBody.class));
        verify(s3Client, times(1)).completeMultipartUpload(any(CompleteMultipartUploadRequest.class));

        // Assert the expected result
        assertEquals("SUCCESS", result);
    }

    @Test
    void testConstructorWithStaticCredentials_Success() throws DataCompareException {
        // Test the constructor with static credentials
        S3DataService s3DataService1 = new S3DataService(
                "testBucket",
                "testKeyId",
                "testAccessKey",
                "us-east-1",
                ""
        );
        assertNotNull(s3DataService1);
    }

    @Test
    void testConstructorWithProfile_Success() throws DataCompareException {
        // Test the constructor with profile credentials
        S3DataService s3DataService1 = new S3DataService(
                "testBucket",
                "",
                "",
                "us-east-1",
                "default"
        );

        assertNotNull(s3DataService1);
    }


    @Test
    void testConstructorThrowsExceptionWhenNoCredentials() {
        // Test the constructor throws exception when no credentials or profile are provided
        Exception exception = assertThrows(DataCompareException.class, () -> {
            new S3DataService(
                    "",
                    "",
                    "",
                    "us-east-1",
                    ""
            );
        });

        assertEquals("No Valid AWS Profile or Credentials found", exception.getMessage());
    }


}
