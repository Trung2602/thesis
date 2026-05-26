package com.lht.services;

import com.lht.dto.CustomerScheduleDTO;
import com.lht.pojo.CustomerSchedule;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import org.springframework.data.domain.Page;

public interface CustomerScheduleService {

    List<CustomerSchedule> getAllCustomerSchedules();

    CustomerScheduleDTO getCustomerScheduleByUuid(UUID uuid);

    List<CustomerScheduleDTO> getCustomerSchedules(Map<String, String> params);

    CustomerSchedule addOrUpdateCustomerSchedule(CustomerScheduleDTO dto);

    boolean deleteCustomerSchedule(UUID uuid);
    void deleteByCustomerUuid(UUID customerUuid);
    void deleteByStaffUuid(UUID customerUuid);
    void deleteByFacilityUuid(UUID facilityUuid);
    Page<CustomerSchedule> getAllSort(String sortField, String sortDir, int page, int size);

    List<CustomerScheduleDTO> getSchedulesByAccount();

    CustomerScheduleDTO updateNote(UUID uuid, String note);

    boolean isScheduleConflict(UUID uuid, UUID staffUuid, LocalDate date, LocalTime checkin, LocalTime checkout);

    Set<UUID> getAvailableStaff(UUID facilityUuid, LocalDate date, LocalTime checkIn, LocalTime checkOut);
}
