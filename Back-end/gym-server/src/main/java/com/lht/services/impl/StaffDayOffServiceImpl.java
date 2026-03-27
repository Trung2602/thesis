package com.lht.services.impl;

import com.lht.client.InternalUserClient;
import com.lht.dto.InternalUserResponse;
import com.lht.dto.StaffDayOffDTO;
import com.lht.jwt.SecurityUtils;
import com.lht.pojo.StaffDayOff;
import com.lht.repositories.StaffDayOffRepository;
import com.lht.services.StaffDayOffService;
import jakarta.persistence.criteria.Predicate;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.stream.Collectors;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.core.context.SecurityContextHolder;
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
                        .build())
                .toList();
    }

    private StaffDayOff toEntity(StaffDayOffDTO dto) {
        StaffDayOff s = new StaffDayOff();
        s.setUuid(dto.getUuid());
        s.setDateOff(dto.getDate());
        return s;
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
            entity.setDateOff(dto.getDate());
        }
        else {
            entity = new StaffDayOff();
            entity.setUuid(UUID.randomUUID());
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
    public Page<StaffDayOffDTO> getAllSort(String sortField, String sortDir, int page, int size) {
        Sort sort = sortDir.equalsIgnoreCase("asc")
                ? Sort.by(sortField).ascending()
                : Sort.by(sortField).descending();
        Pageable pageable = PageRequest.of(page, size, sort);
        Page<StaffDayOff> entityPage = staffDayOffRepository.findAll(pageable);
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
