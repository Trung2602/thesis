package com.lht.services.impl;

import com.lht.client.InternalUserClient;
import com.lht.dto.StaffDayOffDTO;
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
        dto.setStaffUuid(s.getStaffUuid());
        dto.setStaffName(internalUserClient.getStaffNameByUuid(s.getStaffUuid()));
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
                        .staffUuid(d.getStaffUuid())
                        .staffName(staffMap.getOrDefault(d.getStaffUuid(), "Unknown"))
                        .build())
                .toList();
    }

    private StaffDayOff toEntity(StaffDayOffDTO dto) {
        StaffDayOff s = new StaffDayOff();
        s.setUuid(dto.getUuid());
        s.setDateOff(dto.getDate());
        s.setStaffUuid(dto.getStaffUuid());
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

        if (dto.getStaffUuid() == null) throw new IllegalArgumentException("Staff UUID is required");

        boolean exists = internalUserClient.existsByUuid(dto.getStaffUuid());
        if (!exists) throw new IllegalArgumentException("Staff does not exist");

        String staffType = internalUserClient.getStaffType(dto.getStaffUuid());
        if (!"Fulltime".equalsIgnoreCase(staffType)) {
            throw new IllegalArgumentException("Only Fulltime staff can register day off");
        }

        boolean alreadyExists = staffDayOffRepository.existsByStaffUuidAndDateOff(dto.getStaffUuid(), dto.getDate());
        if (alreadyExists) {
            throw new IllegalArgumentException("Day off already registered for this date");
        }

        StaffDayOff entity = toEntity(dto);
        if (entity.getUuid() == null) {
            entity.setUuid(UUID.randomUUID());
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
    public List<StaffDayOffDTO> getStaffDayOffs(Map<String, String> params) {
        Specification<StaffDayOff> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (params.containsKey("staffUuid")) {
                try {
                    UUID staffUuid = UUID.fromString(params.get("staffUuid"));
                    predicates.add(cb.equal(root.get("staffUuid"), staffUuid));
                } catch (IllegalArgumentException e) {
                    throw new IllegalArgumentException("Invalid staffUuid format.");
                }
            }

            if (params.containsKey("date")) {
                try {
                    LocalDate date = LocalDate.parse(params.get("date"));
                    predicates.add(cb.equal(root.get("dateOff"), date));
                } catch (DateTimeParseException e) {
                    throw new IllegalArgumentException("Invalid date format. Expected yyyy-MM-dd.");
                }
            }

            if (params.containsKey("month") && params.containsKey("year")) {
                try {
                    int month = Integer.parseInt(params.get("month"));
                    int year = Integer.parseInt(params.get("year"));

                    LocalDate start = LocalDate.of(year, month, 1);
                    LocalDate end = start.withDayOfMonth(start.lengthOfMonth());

                    predicates.add(cb.between(root.get("dateOff"), start, end));
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("Invalid month/year. Expected number.");
                }
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
        List<StaffDayOff> dayOff = staffDayOffRepository.findAll(spec);
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
    public List<StaffDayOffDTO> getStaffDayOffByStaffUuid(UUID uuid) {
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
