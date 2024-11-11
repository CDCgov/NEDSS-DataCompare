package gov.cdc.datacompareapis.repository.rdb;

import gov.cdc.datacompareapis.repository.rdb.model.DataCompareConfig;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DataCompareConfigRepository extends JpaRepository<DataCompareConfig, Long> {
}
