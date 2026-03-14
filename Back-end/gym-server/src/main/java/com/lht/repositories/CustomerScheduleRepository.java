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

public interface CustomerScheduleRepository extends JpaRepository<CustomerSchedule, UUID>, JpaSpecificationExecutor<CustomerSchedule>{

    List<CustomerSchedule> findByCustomerUuid(UUID customerUuid);

    List<CustomerSchedule> findByStaffUuid(UUID staffUuid);

    List<CustomerSchedule> findByDate(LocalDate date);

    List<CustomerSchedule> findByStaffUuidAndDateAndCheckin(UUID staffUuid, LocalDate date, LocalTime checkin);

    @Query("""
SELECT DISTINCT cs.staffUuid
FROM CustomerSchedule cs
WHERE cs.date = :date
AND cs.checkin < :checkOut
AND cs.checkout > :checkIn
""")
    Set<UUID> findBusyStaff(
            LocalDate date,
            LocalTime checkIn,
            LocalTime checkOut
    );
}
