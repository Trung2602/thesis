package com.lht.repositories;

import com.lht.pojo.StaffSchedule;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface StaffScheduleRepository extends JpaRepository<StaffSchedule, UUID>, JpaSpecificationExecutor<StaffSchedule>{
    
    List<StaffSchedule> findByStaffUuid(UUID staffUuid);

    List<StaffSchedule> findByDate(LocalDate date);

    boolean existsByStaffUuidAndDateAndShiftUuid(UUID staffUuid, LocalDate date, UUID shiftUuid);

    @Query("""
SELECT sc.staffUuid
FROM StaffSchedule sc
JOIN Shift s ON sc.shiftUuid = s.uuid
WHERE sc.date = :date
AND :checkIn >= s.checkin
AND :checkOut <= s.checkout
""")
    List<UUID> findWorkingStaff(
            @Param("date") LocalDate date,
            @Param("checkIn") LocalTime checkIn,
            @Param("checkOut") LocalTime checkOut
    );
}
