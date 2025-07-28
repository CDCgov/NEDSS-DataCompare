package gov.cdc.datacompareapis.controller;


import gov.cdc.datacompareapis.exception.DataCompareException;
import gov.cdc.datacompareapis.service.interfaces.IDataPullerService;
import io.swagger.v3.oas.annotations.Hidden;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static gov.cdc.datacompareapis.shared.NumberHelper.isInteger;

@RestController
@SecurityRequirement(name = "bearer-key")
@Tag(name = "Data Compare", description = "Data Exchange API")
public class DataCompareController {

    private final IDataPullerService dataPullerService;

    public DataCompareController(IDataPullerService dataPullerService) {
        this.dataPullerService = dataPullerService;
    }

    @Operation(
            summary = "Initiating the data comparing process",
            description = "Fetches data from relevant tables then outputs data into JSON and kicks off lower stream process for data comparison.",
            parameters = {
                    @Parameter(in = ParameterIn.HEADER,
                            name = "batchLimit",
                            description = "Flag indicating max records per pulling process",
                            schema = @Schema(type = "Integer", defaultValue = "1000"),
                            required = true),
                    @Parameter(in = ParameterIn.QUERY,
                            name = "runNowMode",
                            description = "Boolean flag to initiate the run immediately",
                            schema = @Schema(type = "Boolean", defaultValue = "false"))
            }
    )
    @GetMapping(path = "/api/data-compare")
    public ResponseEntity<String> dataSyncTotalRecords(
            @RequestHeader(name = "batchLimit", defaultValue = "1000") String batchLimit,
            @RequestHeader(name = "runNowMode", defaultValue = "false") boolean runNowMode) throws DataCompareException {

        if (isInteger(batchLimit)) {
            dataPullerService.pullingData(Integer.parseInt(batchLimit), runNowMode);
            return new ResponseEntity<>("OK", HttpStatus.OK);
        }
        throw new DataCompareException("Invalid Header");
    }

    @Operation(
            summary = "Initiating the data comparing process",
            description = "Fetches data from relevant tables then outputs data into JSON and kicks off lower stream process for data comparison.",
            parameters = {
                    @Parameter(in = ParameterIn.QUERY,
                            name = "runNowMode",
                            description = "Boolean flag to initiate the run immediately",
                            schema = @Schema(type = "boolean", defaultValue = "false")),
                    @Parameter(in = ParameterIn.QUERY,
                            name = "nbsInterfaceUid1",
                            description = "First NBS interface UID",
                            schema = @Schema(type = "number", defaultValue = "0")),
                    @Parameter(in = ParameterIn.QUERY,
                            name = "nbsInterfaceUid2",
                            description = "Second NBS interface UID",
                            schema = @Schema(type = "number", defaultValue = "0"))
            }
    )
    @GetMapping(path = "/api/data-compare-elr")
    public ResponseEntity<String> dataCompareELR(
            @RequestParam(name = "nbsInterfaceUid1", defaultValue = "0") long nbsInterfaceUid1,
            @RequestParam(name = "nbsInterfaceUid2", defaultValue = "0") long nbsInterfaceUid2
    ) throws DataCompareException {

        dataPullerService.pullDataForDataIngestionValidation(nbsInterfaceUid1, nbsInterfaceUid2);
        return new ResponseEntity<>("OK", HttpStatus.OK);
    }

    @Hidden
    @PostMapping(path = "/api/data-compare/health-check")
    public ResponseEntity<String> decodeAndDecompress()  {
        return new ResponseEntity<>(HttpStatus.OK);
    }
}
