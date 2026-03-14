package com.lht.repositories;

import com.lht.pojo.PayCustomer;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface PayCustomerRepository extends JpaRepository<PayCustomer, UUID>, JpaSpecificationExecutor<PayCustomer>{

    List<PayCustomer> findByCustomerUuid(UUID customerUuid);

    Optional<PayCustomer> findByTxnRef(String txnRef);
}
