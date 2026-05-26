package com.lht.services.impl;

import com.lht.dto.ShiftDTO;
import com.lht.pojo.Shift;
import com.lht.repositories.ShiftRepository;
import com.lht.services.ShiftService;
import com.lht.services.StaffScheduleService;
import jakarta.persistence.criteria.Predicate;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.*;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
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
public class ShiftServiceImpl implements ShiftService {

    private final ShiftRepository shiftRepository;
    private final StaffScheduleService staffScheduleService;

    private ShiftDTO mapToDTO(Shift s) {
        return ShiftDTO.builder()
                .uuid(s.getUuid())
                .name(s.getName())
                .checkin(s.getCheckin())
                .checkout(s.getCheckout())
                .duration(s.getDuration())
                .build();
    }

    public static Shift toEntity(ShiftDTO dto) {
        if (dto == null) return null;

        Shift shift = new Shift();
        shift.setUuid(dto.getUuid());
        shift.setName(dto.getName());
        shift.setCheckin(dto.getCheckin());
        shift.setCheckout(dto.getCheckout());
        shift.setDuration(dto.getDuration());
        return shift;
    }

    @Override
    public List<ShiftDTO> getAllShifts() {
        return shiftRepository.findAll().stream()
                .map(this::mapToDTO)
                .toList();
    }

    @Override
    public ShiftDTO getShiftByUuid(UUID uuid) {
        return shiftRepository.findById(uuid).map(this::mapToDTO).orElse(null);
    }

    @Override
    public ShiftDTO addOrUpdateShift(ShiftDTO dto) {
        Shift shift = toEntity(dto);
        if (shift.getDuration() == null) {
            Duration duration = Duration.between(
                    shift.getCheckin(),
                    shift.getCheckout()
            );
            double hours = duration.toMinutes() / 60.0;
            shift.setDuration(BigDecimal.valueOf(hours));
        }
        Shift saved = shiftRepository.save(shift);
        return this.mapToDTO(saved);
    }

    @Override
    public boolean deleteShift(UUID uuid) {
        if (!shiftRepository.existsById(uuid)) return false;

        staffScheduleService.deleteByShiftUuid(uuid);

        shiftRepository.deleteById(uuid);
        return true;
    }

    @Override
    public List<ShiftDTO> getShifts(Map<String, String> params) {
        Specification<Shift> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (params.containsKey("name")) {
                predicates.add(cb.like(cb.lower(root.get("name")), "%" + params.get("name").toLowerCase() + "%"));
            }

            if (params.containsKey("checkin")) {
                try {
                    LocalTime time = LocalTime.parse(params.get("checkin")); // HH:mm:ss
                    predicates.add(cb.equal(root.get("checkin"), time));
                } catch (DateTimeParseException e) {
                    throw new IllegalArgumentException(
                            "Invalid checkin format, expected HH:mm:ss");
                }
            }

            if (params.containsKey("checkout")) {
                try {
                    LocalTime time = LocalTime.parse(params.get("checkout"));
                    predicates.add(cb.equal(root.get("checkout"), time));
                } catch (DateTimeParseException e) {
                    throw new IllegalArgumentException(
                            "Invalid checkout format, expected HH:mm:ss");
                }
            }

            if (params.containsKey("duration")) {
                try {
                    BigDecimal duration = new BigDecimal(params.get("duration"));
                    predicates.add(cb.equal(root.get("duration"), duration));
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException(
                            "Invalid duration, expected decimal number");
                }
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };

        return shiftRepository.findAll(spec).stream()
                .map(this::mapToDTO)
                .toList();
    }

    @Override
    public Page<ShiftDTO> getAllSort(String sortField, String sortDir, int page, int size) {
        Sort sort = sortDir.equalsIgnoreCase("asc")
                ? Sort.by(sortField).ascending()
                : Sort.by(sortField).descending();

        Pageable pageable = PageRequest.of(page, size, sort);
        return shiftRepository.findAll(pageable).map(this::mapToDTO);
    }
}
