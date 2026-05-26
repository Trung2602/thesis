package com.lht.services;

import com.lht.dto.StaffDayOffDTO;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import org.springframework.data.domain.Page;

public interface StaffDayOffService {

    List<StaffDayOffDTO> getAllStaffDayOffs();
    StaffDayOffDTO getStaffDayOffByUuid(UUID uuid);
    StaffDayOffDTO addOrUpdateStaffDayOff(StaffDayOffDTO dto);
    boolean deleteStaffDayOff(UUID uuid);
    void deleteByStaffUuid(UUID staffUuid);
    void deleteByFacilityUuid(UUID facilityUuid);
    List<StaffDayOffDTO> getStaffDayOffs(int month, int year);
    Page<StaffDayOffDTO> getStaffDayOffsFilter(Map<String, String> params, String sortField, String sortDir, int page, int size);
    int countByStaffUuidAndMonthYear(UUID staffUuid, int month, int year);
    List<StaffDayOffDTO> getStaffDayOffByStaffUuid();
    Set<UUID> getStaffsOff(UUID facilityUuid, LocalDate date);
    boolean approveDayOff(UUID uuid);
}
