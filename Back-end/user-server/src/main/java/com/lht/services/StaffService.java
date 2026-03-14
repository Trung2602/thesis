package com.lht.services;

import com.lht.dto.InternalUserResponse;
import com.lht.dto.NameUUIDDTO;
import com.lht.dto.StaffDTO;
import com.lht.dto.StaffRequestDTO;
import com.lht.pojo.Staff;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.*;

public interface StaffService {

    List<StaffDTO> getAllStaffs();
    StaffDTO getStaffByUuid(UUID uuid);
    Staff getByUuid(UUID uuid);
    List<StaffDTO> getStaffs(Map<String, String> params);
    StaffDTO createStaff(StaffRequestDTO dto, MultipartFile file);
    StaffDTO updateStaff(StaffDTO dto, MultipartFile file);
    boolean deleteStaff(UUID uuid);
    List<InternalUserResponse> getStaffsAll();
    String getStaffNameByUuid(UUID uuid);
    Map<UUID, String> getStaffNamesByUuids(Set<UUID> staffUuids);
    String getStaffType(UUID uuid);
    List<UUID> getStaffsFulltime();
    List<NameUUIDDTO> getAvailableStaff(LocalDate date, LocalTime checkin, LocalTime checkout);
}
