package com.lht.repositories;

import com.lht.pojo.CustomerSchedule;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface CustomerScheduleRepository extends JpaRepository<CustomerSchedule, UUID>, JpaSpecificationExecutor<CustomerSchedule>{

    List<CustomerSchedule> findByCustomerUuid(UUID customerUuid);

    List<CustomerSchedule> findByStaffUuid(UUID staffUuid);

    @Query("""
    SELECT cs FROM CustomerSchedule cs
    WHERE cs.staffUuid = :staffUuid
    AND cs.date = :date
    AND cs.checkin < :checkOut
    AND cs.checkout > :checkIn
    """)
    List<CustomerSchedule> findConflicting(
            @Param("staffUuid") UUID staffUuid,
            @Param("date") LocalDate date,
            @Param("checkIn") LocalTime checkIn,
            @Param("checkOut") LocalTime checkOut
    );

    @Query("""
    SELECT DISTINCT cs.staffUuid
    FROM CustomerSchedule cs
    WHERE cs.facilityUuid = :facilityUuid
    AND cs.date = :date
    AND cs.checkin < :checkOut
    AND cs.checkout > :checkIn
    """)
    Set<UUID> findBusyStaff(
            @Param("facilityUuid") UUID facilityUuid,
            @Param("date") LocalDate date,
            @Param("checkIn") LocalTime checkIn,
            @Param("checkOut") LocalTime checkOut
    );
}
