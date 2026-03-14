package com.lht.services.impl;

import com.lht.client.InternalUserClient;
import com.lht.dto.CustomerScheduleDTO;
import com.lht.pojo.CustomerSchedule;
import com.lht.repositories.CustomerScheduleRepository;
import com.lht.services.CustomerScheduleService;
import com.lht.services.FacilityService;
import com.lht.services.StaffDayOffService;
import com.lht.services.StaffScheduleService;
import jakarta.persistence.criteria.Predicate;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
@RequiredArgsConstructor
public class CustomerScheduleServiceImpl implements CustomerScheduleService {

    private final CustomerScheduleRepository customerScheduleRepository;
    private final FacilityService facilityService;
    private final InternalUserClient internalUserClient;
    private final StaffDayOffService staffDayOffService;
    private final StaffScheduleService staffScheduleService;

    private List<CustomerScheduleDTO> mapToDTO(List<CustomerSchedule> schedules) {
        if (schedules.isEmpty()) {
            return List.of();
        }
        // Collect UUIDs
        Set<UUID> customerUuids = schedules.stream()
                .map(CustomerSchedule::getCustomerUuid)
                .collect(Collectors.toSet());
        Set<UUID> staffUuids = schedules.stream()
                .map(CustomerSchedule::getStaffUuid)
                .collect(Collectors.toSet());
        Set<UUID> facilityUuids = schedules.stream()
                .map(CustomerSchedule::getFacilityUuid)
                .collect(Collectors.toSet());
        // Batch call
        Map<UUID, String> customerMap = internalUserClient.getCustomerNamesByUuids(customerUuids);
        Map<UUID, String> staffMap = internalUserClient.getStaffNamesByUuids(staffUuids);
        Map<UUID, String> facilityMap = facilityService.getFacilityNamesByUuids(facilityUuids);
        // Mapping
        return schedules.stream()
                .map(cs -> CustomerScheduleDTO.builder()
                        .uuid(cs.getUuid())
                        .date(cs.getDate())
                        .checkin(cs.getCheckin())
                        .checkout(cs.getCheckout())
                        .customerUuid(cs.getCustomerUuid())
                        .staffUuid(cs.getStaffUuid())
                        .facilityUuid(cs.getFacilityUuid())
                        .customerName(customerMap.getOrDefault(cs.getCustomerUuid(), "Unknown"))
                        .staffName(staffMap.getOrDefault(cs.getStaffUuid(), "Unknown"))
                        .facilityName(facilityMap.getOrDefault(cs.getFacilityUuid(), "Unknown"))
                        .build())
                .toList();
    }


    @Override
    public List<CustomerSchedule> getAllCustomerSchedules() {
        return customerScheduleRepository.findAll();
    }

    @Override
    public CustomerScheduleDTO getCustomerScheduleByUuid(UUID uuid) {
        CustomerSchedule cs = customerScheduleRepository.findById(uuid).orElse(null);
        if (cs == null) {return null;}
        String customerName = internalUserClient.getCustomerNameByUuid(cs.getCustomerUuid());
        String staffName = internalUserClient.getStaffNameByUuid(cs.getStaffUuid());
        String facilityName = facilityService.getFacilityByUuid(cs.getFacilityUuid()).getName();

        CustomerScheduleDTO dto = new CustomerScheduleDTO();
        dto.setUuid(cs.getUuid());
        dto.setDate(cs.getDate());
        dto.setCheckin(cs.getCheckin());
        dto.setCheckout(cs.getCheckout());

        dto.setCustomerUuid(cs.getCustomerUuid());
        dto.setStaffUuid(cs.getStaffUuid());
        dto.setFacilityUuid(cs.getFacilityUuid());

        dto.setCustomerName(customerName);
        dto.setStaffName(staffName);
        dto.setFacilityName(facilityName);

        return dto;
    }

    @Override
    public List<CustomerScheduleDTO> getCustomerSchedules(Map<String, String> params) {

        Specification<CustomerSchedule> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (params.containsKey("uuid") && !params.get("uuid").isBlank()) {
                predicates.add(cb.equal(root.get("uuid"), UUID.fromString(params.get("uuid"))));
            }

            if (params.containsKey("customerUuid") && !params.get("customerUuid").isBlank()) {
                predicates.add(cb.equal(root.get("customerUuid"), UUID.fromString(params.get("customerUuid"))));
            }

            if (params.containsKey("staffUuid") && !params.get("staffUuid").isBlank()) {
                predicates.add(cb.equal(root.get("staffUuid"), UUID.fromString(params.get("staffUuid"))));
            }

            if (params.containsKey("facilityUuid") && !params.get("facilityUuid").isBlank()) {
                predicates.add(cb.equal(root.get("facilityUuid"), UUID.fromString(params.get("facilityUuid"))));
            }

            if (params.containsKey("date") && !params.get("date").isBlank()) {
                LocalDate date = LocalDate.parse(params.get("date"));
                predicates.add(cb.equal(root.get("date"), date));
            }

            if (params.containsKey("checkin") && !params.get("checkin").isBlank()) {
                LocalTime checkin = LocalTime.parse(params.get("checkin"));
                predicates.add(cb.equal(root.get("checkin"), checkin));
            }

            if (params.containsKey("checkout") && !params.get("checkout").isBlank()) {
                LocalTime checkout = LocalTime.parse(params.get("checkout"));
                predicates.add(cb.equal(root.get("checkout"), checkout));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };

        List<CustomerSchedule> schedules = customerScheduleRepository.findAll(spec);
        return mapToDTO(schedules);
    }

    @Override
    public CustomerSchedule addOrUpdateCustomerSchedule(CustomerSchedule s) {
        return customerScheduleRepository.save(s);
    }

    @Override
    public boolean deleteCustomerSchedule(UUID uuid) {
        if (customerScheduleRepository.existsById(uuid)) {
            customerScheduleRepository.deleteById(uuid);
            return true;
        }
        return false;
    }

    @Override
    public Page<CustomerSchedule> getAllSort(String sortField, String sortDir, int page, int size) {
        Sort sort = sortDir.equalsIgnoreCase("asc")
                ? Sort.by(sortField).ascending()
                : Sort.by(sortField).descending();
        Pageable pageable = PageRequest.of(page, size, sort);
        return customerScheduleRepository.findAll(pageable);
    }

    @Override
    public List<CustomerScheduleDTO> getCustomerSchedulesByCustomerUuid(UUID customerUuid) {
        List<CustomerSchedule> schedules = customerScheduleRepository.findByCustomerUuid(customerUuid);
        return mapToDTO(schedules);
    }

    @Override
    public List<CustomerScheduleDTO> getCustomerSchedulesByStaffUuid(UUID staffUuid) {
        List<CustomerSchedule> schedules = customerScheduleRepository.findByStaffUuid(staffUuid);
        return mapToDTO(schedules);
    }

    @Override
    public boolean isScheduleConflict(UUID uuid, UUID staffUuid, LocalDate date, LocalTime checkin) {
        List<CustomerSchedule> existing = customerScheduleRepository.findByStaffUuidAndDateAndCheckin(staffUuid, date, checkin);

        if (uuid == null) {
            return !existing.isEmpty();
        }

        return existing.stream().anyMatch(e -> !e.getUuid().equals(uuid));
    }

    @Override
    public Set<UUID> getAvailableStaff(LocalDate date, LocalTime checkIn, LocalTime checkOut) {

        Set<UUID> workingStaff = new HashSet<>();
        workingStaff.addAll(staffDayOffService.getStaffsWorking(date, checkIn, checkOut));
        workingStaff.addAll(staffScheduleService.getStaffsWorking(date, checkIn, checkOut));

        Set<UUID> busyStaff = customerScheduleRepository.findBusyStaff(date, checkIn, checkOut);

        workingStaff.removeAll(busyStaff);
        return workingStaff;
    }
}
