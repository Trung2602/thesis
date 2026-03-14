package com.lht.repositories;

import com.lht.pojo.StaffDayOff;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface StaffDayOffRepository extends JpaRepository<StaffDayOff, UUID>, JpaSpecificationExecutor<StaffDayOff> {

    List<StaffDayOff> findByStaffUuid(UUID staffUuid);

    boolean existsByStaffUuidAndDateOff(UUID staffUuid, LocalDate dateOff);

    long countByStaffUuidAndDateOffBetween(UUID staffUuid, LocalDate start, LocalDate end);

    List<StaffDayOff> findByDateOff(LocalDate dateOff);
}
