package gov.cdc.datacompareapis.repository.rdb;

import gov.cdc.datacompareapis.repository.rdb.model.DataCompareConfig;
import gov.cdc.datacompareapis.repository.rdb.model.DataCompareLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DataCompareLogRepository extends JpaRepository<DataCompareLog, Long> {
}
