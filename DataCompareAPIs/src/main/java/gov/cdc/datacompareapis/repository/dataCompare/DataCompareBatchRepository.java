package gov.cdc.datacompareapis.repository.dataCompare;

import gov.cdc.datacompareapis.repository.dataCompare.model.DataCompareBatch;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DataCompareBatchRepository extends JpaRepository<DataCompareBatch, Long> {
}
