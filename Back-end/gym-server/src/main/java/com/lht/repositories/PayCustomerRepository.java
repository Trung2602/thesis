package com.lht.repositories;

import com.lht.pojo.PayCustomer;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;

public interface PayCustomerRepository extends JpaRepository<PayCustomer, UUID>, JpaSpecificationExecutor<PayCustomer>{

    List<PayCustomer> findByCustomerUuid(UUID customerUuid);

    @Query("""
    SELECT MONTH(p.date), SUM(pl.price)
    FROM PayCustomer p
    JOIN Plan pl ON p.planUuid = pl.uuid
    WHERE p.status = 'SUCCESS' AND YEAR(p.date) = :year
    GROUP BY MONTH(p.date)
    ORDER BY MONTH(p.date)
    """)
    List<Object[]> getMonthlyRevenue(int year);

    @Query("""
    SELECT p.date, SUM(pl.price)
    FROM PayCustomer p
    JOIN Plan pl ON p.planUuid = pl.uuid
    WHERE p.status = 'SUCCESS' AND YEAR(p.date) = :year
    GROUP BY p.date
    ORDER BY p.date
    """)
    List<Object[]> getDailyRevenue(int year);
}
