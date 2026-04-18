package com.lht.services;

import com.lht.dto.StaffScheduleDTO;
import com.lht.pojo.StaffSchedule;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import org.springframework.data.domain.Page;

public interface StaffScheduleService {

    List<StaffScheduleDTO> getAllStaffSchedules();

    StaffScheduleDTO getStaffScheduleByUuid(UUID uuid);

    StaffScheduleDTO addOrUpdateStaffSchedule(StaffScheduleDTO dto);

    boolean deleteStaffSchedule(UUID uuid);

    List<StaffScheduleDTO> getStaffSchedules(Map<String, String> params);

    List<StaffScheduleDTO> getStaffSchedulesByStaffUuid(Map<String, String> params);

    Page<StaffScheduleDTO> getAllSort(String sortField, String sortDir, int page, int size);

    List<StaffScheduleDTO> getStaffScheduleByStaffUuid();

    BigDecimal sumDurationByStaffUuidAndMonthYear(UUID staffUuid, int month, int year);

    List<UUID> getStaffsWorking(LocalDate date, LocalTime checkIn, LocalTime checkOut);
}
