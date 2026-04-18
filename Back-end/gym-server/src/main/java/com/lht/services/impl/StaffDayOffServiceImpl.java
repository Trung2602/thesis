package com.lht.services.impl;

import com.lht.client.InternalUserClient;
import com.lht.dto.StaffDayOffDTO;
import com.lht.component.SecurityUtils;
import com.lht.pojo.StaffDayOff;
import com.lht.repositories.StaffDayOffRepository;
import com.lht.services.StaffDayOffService;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
@RequiredArgsConstructor
public class StaffDayOffServiceImpl implements StaffDayOffService {

    private final StaffDayOffRepository staffDayOffRepository;
    private final InternalUserClient internalUserClient;

    private StaffDayOffDTO mapToDTO(StaffDayOff s) {
        StaffDayOffDTO dto = new StaffDayOffDTO();
        dto.setUuid(s.getUuid());
        dto.setDate(s.getDateOff());
        dto.setName(internalUserClient.getStaffNameByUuid(s.getStaffUuid()));
        return dto;
    }

    private List<StaffDayOffDTO> mapToDTO(List<StaffDayOff> dayOffs) {
        if (dayOffs.isEmpty()) {
            return List.of();
        }
        Set<UUID> staffUuids = dayOffs.stream()
                .map(StaffDayOff::getStaffUuid)
                .collect(Collectors.toSet());
        Map<UUID, String> staffMap = internalUserClient.getStaffNamesByUuids(staffUuids);
        return dayOffs.stream()
                .map(d -> StaffDayOffDTO.builder()
                        .uuid(d.getUuid())
                        .date(d.getDateOff())
                        .name(staffMap.get(d.getStaffUuid()))
                        .build())
                .toList();
    }

    @Override
    public List<StaffDayOffDTO> getAllStaffDayOffs() {
        return mapToDTO(staffDayOffRepository.findAll());
    }

    @Override
    public StaffDayOffDTO getStaffDayOffByUuid(UUID uuid) {
        return staffDayOffRepository.findById(uuid).map(this::mapToDTO).orElse(null);
    }

    @Override
    public StaffDayOffDTO addOrUpdateStaffDayOff(StaffDayOffDTO dto) {
        UUID staffUuid = SecurityUtils.getCurrentUserUuid();
        String staffType = internalUserClient.getStaffType(staffUuid);
        if (!"Fulltime".equalsIgnoreCase(staffType)) {
            throw new IllegalArgumentException("Only Fulltime staff can register day off");
        }
        if (dto.getUuid() == null) {
            boolean alreadyExists = staffDayOffRepository.existsByStaffUuidAndDateOff(staffUuid, dto.getDate());
            if (alreadyExists) {
                throw new IllegalArgumentException("Day off already registered for this date");
            }
        }
        StaffDayOff entity;
        if (dto.getUuid() != null) {
            entity = staffDayOffRepository.findById(dto.getUuid()).orElseThrow(() -> new RuntimeException("Day off not found"));
            if (!entity.getStaffUuid().equals(staffUuid)) {
                throw new RuntimeException("Forbidden");
            }
            if (!dto.getDate().isAfter(LocalDate.now())) {
                throw new RuntimeException("Cannot update past or today's day off. Only future dates allowed.");
            }
            entity.setDateOff(dto.getDate());
        }
        else {
            entity = new StaffDayOff();
            entity.setStaffUuid(staffUuid);
            entity.setDateOff(dto.getDate());
        }

        StaffDayOff saved = staffDayOffRepository.save(entity);
        return mapToDTO(saved);
    }

    @Override
    public boolean deleteStaffDayOff(UUID uuid) {
        if (staffDayOffRepository.existsById(uuid)) {
            staffDayOffRepository.deleteById(uuid);
            return true;
        }
        return false;
    }

    @Override
    public List<StaffDayOffDTO> getStaffDayOffs(int month, int year) {
        UUID uuid = SecurityUtils.getCurrentUserUuid();
        LocalDate start = LocalDate.of(year, month, 1);
        LocalDate end = start.withDayOfMonth(start.lengthOfMonth());
        List<StaffDayOff> dayOff = staffDayOffRepository.findByStaffUuidAndDateOffBetween(uuid, start, end);
        return mapToDTO(dayOff);
    }

    @Override
    public Page<StaffDayOffDTO> getStaffDayOffsFilter(Map<String, String> params, String sortField, String sortDir, int page, int size) {
        Specification<StaffDayOff> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (params.containsKey("uuid") && !params.get("uuid").isBlank()) {
                predicates.add(cb.equal(
                        root.get("uuid"),
                        UUID.fromString(params.get("uuid"))
                ));
            }
            if (params.containsKey("staffUuid") && !params.get("staffUuid").isBlank()) {
                predicates.add(cb.equal(
                        root.get("staffUuid"),
                        UUID.fromString(params.get("staffUuid"))
                ));
            }
            if (params.containsKey("month") && params.containsKey("year")
                    && !params.get("month").isBlank()
                    && !params.get("year").isBlank()) {

                int month = Integer.parseInt(params.get("month"));
                int year = Integer.parseInt(params.get("year"));

                LocalDate start = LocalDate.of(year, month, 1);
                LocalDate end = start.withDayOfMonth(start.lengthOfMonth());

                predicates.add(cb.between(root.get("dateOff"), start, end));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
        if (sortField == null || sortField.isBlank()) {
            sortField = "dateOff";
        }
        if (sortDir == null || sortDir.isBlank()) {
            sortDir = "desc";
        }
        Sort sort = sortDir.equalsIgnoreCase("asc")
                ? Sort.by(sortField).ascending()
                : Sort.by(sortField).descending();
        Pageable pageable = PageRequest.of(page, size, sort);
        Page<StaffDayOff> entityPage = staffDayOffRepository.findAll(spec, pageable);
        List<StaffDayOffDTO> dtoList = mapToDTO(entityPage.getContent());
        return new PageImpl<>(dtoList, pageable, entityPage.getTotalElements());
    }


    @Override
    public int countByStaffUuidAndMonthYear(UUID staffUuid, int month, int year) {

        LocalDate start = LocalDate.of(year, month, 1);
        LocalDate end = start.withDayOfMonth(start.lengthOfMonth());

        return (int) staffDayOffRepository.countByStaffUuidAndDateOffBetween(staffUuid, start, end);
    }

    @Override
    public List<StaffDayOffDTO> getStaffDayOffByStaffUuid() {
        UUID uuid = SecurityUtils.getCurrentUserUuid();
        return mapToDTO(staffDayOffRepository.findByStaffUuid(uuid));
    }

    private static final LocalTime FULLTIME_START = LocalTime.of(5, 0);
    private static final LocalTime FULLTIME_END = LocalTime.of(21, 0);

    @Override
    public List<UUID> getStaffsWorking(LocalDate date, LocalTime checkIn, LocalTime checkOut) {
        boolean validFulltime = !checkIn.isBefore(FULLTIME_START) && !checkOut.isAfter(FULLTIME_END);
        if (!validFulltime) {
            return Collections.emptyList();
        }
        // lấy tất cả FULLTIME từ user-server
        List<UUID> fulltimeStaff = new ArrayList<>(internalUserClient.getStaffsFulltime());
        List<StaffDayOff> offDays = staffDayOffRepository.findByDateOff(date);
        Set<UUID> offStaff = offDays.stream()
                .map(StaffDayOff::getStaffUuid)
                .collect(Collectors.toSet());

        fulltimeStaff.removeAll(offStaff);
        return fulltimeStaff;
    }
}
