package gov.cdc.datacompareprocessor.repository.dataCompare;

import gov.cdc.datacompareprocessor.repository.dataCompare.model.DataCompareLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository

public interface DataCompareLogRepository extends JpaRepository<DataCompareLog, Long> {
}
