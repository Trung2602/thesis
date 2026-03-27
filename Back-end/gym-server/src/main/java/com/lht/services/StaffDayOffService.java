package com.lht.services;

import com.lht.dto.StaffDayOffDTO;
import com.lht.pojo.StaffDayOff;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.data.domain.Page;

public interface StaffDayOffService {

    List<StaffDayOffDTO> getAllStaffDayOffs();
    StaffDayOffDTO getStaffDayOffByUuid(UUID uuid);
    StaffDayOffDTO addOrUpdateStaffDayOff(StaffDayOffDTO dto);
    boolean deleteStaffDayOff(UUID uuid);

    public List<StaffDayOffDTO> getStaffDayOffs(int month, int year);
    Page<StaffDayOffDTO> getAllSort(String sortField, String sortDir, int page, int size);
    int countByStaffUuidAndMonthYear(UUID staffUuid, int month, int year);
    List<StaffDayOffDTO> getStaffDayOffByStaffUuid();
    List<UUID> getStaffsWorking(LocalDate date, LocalTime checkIn, LocalTime checkOut);
}
