package com.lht.services.impl;

import com.lht.client.InternalUserClient;
import com.lht.dto.StaffScheduleDTO;
import com.lht.component.SecurityUtils;
import com.lht.pojo.Shift;
import com.lht.pojo.StaffSchedule;
import com.lht.repositories.ShiftRepository;
import com.lht.repositories.StaffDayOffRepository;
import com.lht.repositories.StaffScheduleRepository;
import com.lht.services.StaffScheduleService;
import jakarta.persistence.criteria.Predicate;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
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
public class StaffScheduleServiceImpl implements StaffScheduleService {

    private final StaffScheduleRepository staffScheduleRepository;
    private final InternalUserClient internalUserClient;
    private final ShiftRepository shiftRepository;
    private final StaffDayOffRepository staffDayOffRepository;

    private StaffScheduleDTO mapToDTO(StaffSchedule s) {
        StaffScheduleDTO dto = new StaffScheduleDTO();
        dto.setUuid(s.getUuid());
        dto.setDate(s.getDate());
        dto.setShiftUuid(s.getShiftUuid());
        dto.setStaffName(internalUserClient.getStaffNameByUuid(s.getStaffUuid()));

        Shift shift = shiftRepository.findById(s.getShiftUuid()).orElse(null);
        if (shift != null) {
            dto.setShiftName(shift.getName());
        }
        return dto;
    }

    private List<StaffScheduleDTO> mapToDTO(List<StaffSchedule> schedules) {
        if (schedules.isEmpty()) {return List.of();}
        Set<UUID> staffUuids = schedules.stream()
                .map(StaffSchedule::getStaffUuid)
                .collect(Collectors.toSet());
        Set<UUID> shiftUuids = schedules.stream()
                .map(StaffSchedule::getShiftUuid)
                .collect(Collectors.toSet());

        Map<UUID, String> staffMap = internalUserClient.getStaffNamesByUuids(staffUuids);
        List<Shift> shifts = shiftRepository.findAllById(shiftUuids);
        Map<UUID, Shift> shiftMap = shifts.stream().collect(Collectors.toMap(Shift::getUuid, s -> s));

        return schedules.stream()
                .map(s -> {
                    Shift shift = shiftMap.get(s.getShiftUuid());
                    return StaffScheduleDTO.builder()
                            .uuid(s.getUuid())
                            .date(s.getDate())
                            .staffName(staffMap.getOrDefault(s.getStaffUuid(), "Unknown"))
                            .shiftUuid(s.getShiftUuid())
                            .shiftName(shift != null ? shift.getName() : null)
                            .build();
                })
                .toList();
    }

    @Override
    public List<StaffScheduleDTO> getAllStaffSchedules() {
        return mapToDTO(staffScheduleRepository.findAll());
    }

    @Override
    public StaffScheduleDTO getStaffScheduleByUuid(UUID uuid) {
        return staffScheduleRepository.findById(uuid).map(this::mapToDTO).orElse(null);
    }

    @Override
    public StaffScheduleDTO addOrUpdateStaffSchedule(StaffScheduleDTO dto) {
        UUID uuid = SecurityUtils.getCurrentUserUuid();
        Shift shift = shiftRepository.findById(dto.getShiftUuid()).orElseThrow(() -> new IllegalArgumentException("Shift does not exist"));
        boolean conflict = staffScheduleRepository.existsByStaffUuidAndDateAndShiftUuid(uuid, dto.getDate(), dto.getShiftUuid());
        if (conflict) {
            throw new IllegalStateException("Staff already has this shift");
        }
        StaffSchedule entity;
        if (dto.getUuid() != null) {
            entity = staffScheduleRepository.findById(dto.getUuid()).orElseThrow(() -> new IllegalArgumentException("Staff schedule not found"));
        } else {
            entity = new StaffSchedule();
        }

        entity.setDate(dto.getDate());
        entity.setShiftUuid(dto.getShiftUuid());
        entity.setStaffUuid(SecurityUtils.getCurrentUserUuid());
        StaffSchedule saved = staffScheduleRepository.save(entity);
        return mapToDTO(saved);
    }

    @Override
    public boolean deleteStaffSchedule(UUID uuid) {
        if (staffScheduleRepository.existsById(uuid)) {
            staffScheduleRepository.deleteById(uuid);
            return true;
        }
        return false;
    }

    @Override
    public List<StaffScheduleDTO> getStaffSchedules(Map<String, String> params) {
        UUID uuid = SecurityUtils.getCurrentUserUuid();
        Specification<StaffSchedule> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            UUID staffUuid;
            if (params.containsKey("staffUuid")) {
                try {
                    staffUuid = UUID.fromString(params.get("staffUuid"));
                } catch (IllegalArgumentException e) {
                    throw new IllegalArgumentException("Invalid staffUuid format");
                }
            } else {
                staffUuid = uuid;
            }
            predicates.add(cb.equal(root.get("staffUuid"), staffUuid));

            if (params.containsKey("shiftUuid")) {
                try {
                    UUID shiftUuid = UUID.fromString(params.get("shiftUuid"));
                    predicates.add(cb.equal(root.get("shiftUuid"), shiftUuid));
                } catch (IllegalArgumentException e) {
                    throw new IllegalArgumentException("Invalid shiftUuid format");
                }
            }

            if (params.containsKey("date")) {
                try {
                    LocalDate date = LocalDate.parse(params.get("date"));
                    predicates.add(cb.equal(root.get("date"), date));
                } catch (DateTimeParseException e) {
                    throw new IllegalArgumentException("Invalid date format, expected yyyy-MM-dd");
                }
            }

            if (params.containsKey("month") && params.containsKey("year")) {
                try {
                    int month = Integer.parseInt(params.get("month"));
                    int year = Integer.parseInt(params.get("year"));

                    LocalDate start = LocalDate.of(year, month, 1);
                    LocalDate end = start.withDayOfMonth(start.lengthOfMonth());

                    predicates.add(cb.between(root.get("date"), start, end));

                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("Invalid month/year");
                }
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
        List<StaffSchedule> schedules = staffScheduleRepository.findAll(spec);
        return mapToDTO(schedules);
    }

    @Override
    public Page<StaffScheduleDTO> getAllSort(String sortField, String sortDir, int page, int size) {
        Sort sort = sortDir.equalsIgnoreCase("asc")
                ? Sort.by(sortField).ascending()
                : Sort.by(sortField).descending();
        Pageable pageable = PageRequest.of(page, size, sort);
        Page<StaffSchedule> result = staffScheduleRepository.findAll(pageable);
        return result.map(this::mapToDTO);
    }

    @Override
    public List<StaffScheduleDTO> getStaffScheduleByStaffUuid(UUID uuid) {
        List<StaffSchedule> schedules = staffScheduleRepository.findByStaffUuid(uuid);
        return mapToDTO(schedules);
    }

    @Override
    public BigDecimal sumDurationByStaffUuidAndMonthYear(UUID staffUuid, int month, int year) {

        List<StaffSchedule> schedules = staffScheduleRepository.findByStaffUuid(staffUuid);
        if (schedules.isEmpty()) {
            return BigDecimal.ZERO;
        }

        List<StaffSchedule> filteredSchedules = schedules.stream().filter(s -> s.getDate().getMonthValue() == month && s.getDate().getYear() == year).toList();
        if (filteredSchedules.isEmpty()) {
            return BigDecimal.ZERO;
        }

        Set<UUID> shiftUuids = filteredSchedules.stream()
                .map(StaffSchedule::getShiftUuid).collect(Collectors.toSet());
        List<Shift> shifts = shiftRepository.findAllById(shiftUuids);
        Map<UUID, BigDecimal> shiftDurationMap = shifts.stream()
                .collect(Collectors.toMap(
                        Shift::getUuid,
                        Shift::getDuration
                ));

        BigDecimal total = BigDecimal.ZERO;
        for (StaffSchedule schedule : filteredSchedules) {
            BigDecimal duration =
                    shiftDurationMap.getOrDefault(
                            schedule.getShiftUuid(),
                            BigDecimal.ZERO);

            total = total.add(duration);
        }
        return total;
    }

    @Override
    public List<UUID> getStaffsWorking(LocalDate date, LocalTime checkIn, LocalTime checkOut) {
        return staffScheduleRepository.findWorkingStaff(date, checkIn, checkOut);
    }
}
