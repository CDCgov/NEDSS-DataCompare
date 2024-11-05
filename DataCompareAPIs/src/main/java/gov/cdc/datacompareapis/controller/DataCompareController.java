package gov.cdc.datacompareapis.controller;


import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.RestController;

@RestController
@SecurityRequirement(name = "bearer-key")
@Tag(name = "Data Compare", description = "Data Exchange API")
public class DataCompareController {
}
