package com.lht.services.impl;

import com.lht.client.InternalUserClient;
import com.lht.dto.StaffDayOffDTO;
import com.lht.component.SecurityUtils;
import com.lht.dto.StaffScheduleDTO;
import com.lht.pojo.StaffDayOff;
import com.lht.pojo.StaffSchedule;
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
        dto.setFacilityUuid(s.getFacilityUuid());
        dto.setReason(s.getReason());
        dto.setApproved(s.getApproved());
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
                        .facilityUuid(d.getFacilityUuid())
                        .reason(d.getReason())
                        .approved(d.getApproved())
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
        UUID currentUuid = SecurityUtils.getCurrentUserUuid();
        String role = SecurityUtils.getCurrentUserRole();
        UUID staffUuid;
        if ("ADMIN".equals(role)) {
            if (dto.getStaffUuid() == null) {
                throw new IllegalArgumentException("staffUuid is required for admin");
            }
            staffUuid = dto.getStaffUuid();
        } else {
            String staffType = internalUserClient.getStaffType(currentUuid);

            if (!"Fulltime".equalsIgnoreCase(staffType)) {
                throw new IllegalArgumentException("Only Fulltime staff can register day off");
            }

            staffUuid = currentUuid;
        }

        UUID facilityUuid = dto.getFacilityUuid();

        if (facilityUuid == null) {
            facilityUuid = internalUserClient.getFacilityUuidbyStaffUuid(staffUuid);
        }

        if (dto.getUuid() == null) {
            boolean alreadyExists = staffDayOffRepository.existsByStaffUuidAndDateOff(staffUuid, dto.getDate());
            if (alreadyExists) {
                throw new IllegalArgumentException("Day off already registered for this date");
            }
        }

        StaffDayOff entity;
        if (dto.getUuid() != null) {
            entity = staffDayOffRepository.findById(dto.getUuid())
                    .orElseThrow(() -> new RuntimeException("Day off not found"));
            if (!"ADMIN".equals(role)
                    && !entity.getStaffUuid().equals(staffUuid)) {
                throw new RuntimeException("Forbidden");
            }
            if (!dto.getDate().isAfter(LocalDate.now())) {
                throw new RuntimeException(
                        "Cannot update past or today's day off."
                );
            }
            entity.setDateOff(dto.getDate());
            entity.setReason(dto.getReason());
            entity.setFacilityUuid(facilityUuid);
            if (dto.getApproved() != null) {
                entity.setApproved(dto.getApproved());
            }
        } else {
            entity = new StaffDayOff();
            entity.setStaffUuid(staffUuid);
            entity.setDateOff(dto.getDate());
            entity.setReason(dto.getReason());
            entity.setFacilityUuid(facilityUuid);
            entity.setApproved("ADMIN".equals(role));
        }
        return mapToDTO(staffDayOffRepository.save(entity));
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

    @Override
    public Set<UUID> getStaffsOff(UUID facilityUuid, LocalDate date) {
        return staffDayOffRepository.findApprovedLeave(facilityUuid, date);
    }

    @Override
    public boolean approveDayOff(UUID uuid) {
        StaffDayOff entity = staffDayOffRepository.findById(uuid).orElse(null);
        if (entity == null) return false;

        entity.setApproved(true);
        staffDayOffRepository.save(entity);
        return true;
    }
}
