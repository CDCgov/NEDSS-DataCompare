package gov.cdc.datacompareapis.repository.dataCompare;

import gov.cdc.datacompareapis.repository.dataCompare.model.DataCompareConfig;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DataCompareConfigRepository extends JpaRepository<DataCompareConfig, Long> {
}
