package com.lht.repositories;

import com.lht.pojo.BodyLog;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface BodyLogRepository extends JpaRepository<BodyLog, UUID> {
    List<BodyLog> findByCustomerUuidOrderByLoggedAtDesc(UUID customerUuid, Pageable pageable);
    List<BodyLog> findByCustomerUuidOrderByLoggedAtDesc(UUID customerUuid);
}