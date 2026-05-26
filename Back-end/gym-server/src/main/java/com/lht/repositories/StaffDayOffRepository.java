package com.lht.repositories;

import com.lht.pojo.StaffDayOff;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface StaffDayOffRepository extends JpaRepository<StaffDayOff, UUID>, JpaSpecificationExecutor<StaffDayOff> {

    List<StaffDayOff> findByStaffUuid(UUID staffUuid);

    boolean existsByStaffUuidAndDateOff(UUID staffUuid, LocalDate dateOff);

    long countByStaffUuidAndDateOffBetween(UUID staffUuid, LocalDate start, LocalDate end);

    List<StaffDayOff> findByStaffUuidAndDateOffBetween(UUID staffUuid, LocalDate start, LocalDate end);

    List<StaffDayOff> findByDateOff(LocalDate dateOff);

    @Query("""
    SELECT d.staffUuid
    FROM StaffDayOff d
    WHERE d.facilityUuid = :facilityUuid
    AND d.dateOff = :date
    AND d.approved = true
    """)
    Set<UUID> findApprovedLeave(
            @Param("facilityUuid") UUID facilityUuid,
            @Param("date") LocalDate date
    );
}
