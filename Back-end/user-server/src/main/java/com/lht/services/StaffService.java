package com.lht.services;

import com.lht.dto.*;
import com.lht.pojo.Staff;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.*;

public interface StaffService {

    List<AccountLiteDTO> getStaffs();
    StaffDTO getStaffByUuid(UUID uuid);
    List<StaffDTO> getStaffs(Map<String, String> params);
    StaffDTO createStaff(StaffRequestDTO dto);
    StaffDTO updateStaff(StaffRequestDTO dto);

    List<InternalUserResponse> getStaffsAll();
    String getStaffNameByUuid(UUID uuid);
    Map<UUID, String> getStaffNamesByUuids(Set<UUID> staffUuids);
    String getStaffType(UUID uuid);
    List<UUID> getStaffsFulltime();
    List<AvailableStaffDTO> getAvailableStaff(LocalDate date, LocalTime checkin, LocalTime checkout);
}
