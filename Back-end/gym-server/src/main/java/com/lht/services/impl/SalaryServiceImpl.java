package com.lht.services.impl;

import com.lht.client.InternalUserClient;
import com.lht.dto.InternalUserResponse;
import com.lht.dto.SalaryDTO;
import com.lht.pojo.Salary;
import com.lht.repositories.SalaryRepository;
import com.lht.services.SalaryService;
import com.lht.services.StaffDayOffService;
import com.lht.services.StaffScheduleService;

import jakarta.persistence.criteria.Predicate;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
@RequiredArgsConstructor
public class SalaryServiceImpl implements SalaryService {

    private final SalaryRepository salaryRepository;
    private final StaffDayOffService staffDayOffService;
    private final StaffScheduleService staffScheduleService;
    private final InternalUserClient internalUserClient;

    private SalaryDTO mapToDTO(Salary s) {

        SalaryDTO dto = new SalaryDTO();

        dto.setUuid(s.getUuid());
        dto.setDate(s.getDate());
        dto.setDuration(s.getDuration());
        dto.setDayOff(s.getDayOff());
        dto.setPrice(s.getPrice());
        dto.setStaffUuid(s.getStaffUuid());

        dto.setStaffName(internalUserClient.getStaffNameByUuid(s.getStaffUuid()));

        return dto;
    }

    private List<SalaryDTO> mapToDTO(List<Salary> salaries) {
        if (salaries.isEmpty()) {return List.of();}

        Set<UUID> staffUuids = salaries.stream().map(Salary::getStaffUuid).collect(Collectors.toSet());

        Map<UUID, String> staffMap = internalUserClient.getStaffNamesByUuids(staffUuids);

        return salaries.stream()
                .map(s -> SalaryDTO.builder()
                        .uuid(s.getUuid())
                        .date(s.getDate())
                        .duration(s.getDuration())
                        .dayOff(s.getDayOff())
                        .price(s.getPrice())
                        .staffUuid(s.getStaffUuid())
                        .staffName(staffMap.getOrDefault(s.getStaffUuid(), "Unknown"))
                        .build())
                .toList();
    }

    private Salary toEntity(SalaryDTO dto) {
        Salary s = new Salary();

        s.setUuid(dto.getUuid());
        s.setDate(dto.getDate());
        s.setDuration(dto.getDuration());
        s.setDayOff(dto.getDayOff());
        s.setPrice(dto.getPrice());
        s.setStaffUuid(dto.getStaffUuid());

        return s;
    }

    @Override
    public SalaryDTO getSalaryByUuid(UUID uuid) {
        Salary salary = salaryRepository.findById(uuid).orElse(null);

        if (salary == null)
            return null;

        return mapToDTO(salary);
    }

    @Override
    public SalaryDTO addOrUpdateSalary(SalaryDTO dto) {
        Salary s = toEntity(dto);
        Salary saved = salaryRepository.save(s);
        return mapToDTO(saved);
    }

    @Override
    public boolean deleteSalary(UUID uuid) {
        if (salaryRepository.existsById(uuid)) {
            salaryRepository.deleteById(uuid);
            return true;
        }
        return false;
    }

    @Override
    public void deleteByStaffUuid(UUID staffUuid) {
        salaryRepository.deleteByStaffUuid(staffUuid);
    }

    @Override
    public Page<SalaryDTO> getSalariesFilter(Map<String, String> params, String sortField, String sortDir, int page, int size) {
        Specification<Salary> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (params.containsKey("uuid") && !params.get("uuid").isBlank()) {
                predicates.add(cb.equal(root.get("uuid"),
                        UUID.fromString(params.get("uuid"))));
            }

            if (params.containsKey("month") && params.containsKey("year")
                    && !params.get("month").isBlank()
                    && !params.get("year").isBlank()) {

                int month = Integer.parseInt(params.get("month"));
                int year = Integer.parseInt(params.get("year"));

                LocalDate start = LocalDate.of(year, month, 1);
                LocalDate end = start.withDayOfMonth(start.lengthOfMonth());

                predicates.add(cb.between(root.get("date"), start, end));
            }

            if (params.containsKey("staffUuid") && !params.get("staffUuid").isBlank()) {
                predicates.add(cb.equal(root.get("staffUuid"),
                        UUID.fromString(params.get("staffUuid"))));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
        Sort sort = sortDir.equalsIgnoreCase("asc")
                ? Sort.by(sortField).ascending()
                : Sort.by(sortField).descending();
        Pageable pageable = PageRequest.of(page, size, sort);
        Page<Salary> salaryPage = salaryRepository.findAll(spec, pageable);
        List<SalaryDTO> dtoList = mapToDTO(salaryPage.getContent());

        return new PageImpl<>(dtoList, pageable, salaryPage.getTotalElements());
    }

    @Override
    public List<SalaryDTO> getSalaryByStaffUuid(UUID uuid) {
        List<Salary> salaries = salaryRepository.findByStaffUuid(uuid);
        return mapToDTO(salaries);
    }


//=================================================================================
    @Override
    public void calculateMonthlySalaries(int month, int year) {
        List<InternalUserResponse> staffList = internalUserClient.getAllStaffs();
        for (InternalUserResponse staff : staffList) {
            if (!"STAFF".equalsIgnoreCase(staff.role())) {
                continue;
            }
            UUID staffUuid = staff.uuid();
            int totalDayOff = staffDayOffService.countByStaffUuidAndMonthYear(staffUuid, month, year);
            BigDecimal duration = BigDecimal.ZERO;
            BigDecimal totalSalary = BigDecimal.ZERO;
            String staffType = staff.staffType();
            BigDecimal baseSalary = staff.baseSalary();

            if ("Fulltime".equalsIgnoreCase(staffType)) {
                duration = BigDecimal.valueOf(240);
                int allowedDayOff = 2;
                int extraDayOff = Math.max(totalDayOff - allowedDayOff, 0);
                BigDecimal penalty = BigDecimal.valueOf(extraDayOff).multiply(BigDecimal.valueOf(500000));
                totalSalary = baseSalary.subtract(penalty);
            } else if ("PartTime".equalsIgnoreCase(staffType) || "Intern".equalsIgnoreCase(staffType)) {
                duration = staffScheduleService.sumDurationByStaffUuidAndMonthYear(staffUuid, month, year);
                totalSalary = baseSalary.multiply(duration);
            }

            Salary salary = new Salary();
            salary.setStaffUuid(staffUuid);
            salary.setDate(LocalDate.of(year, month, 10));
            salary.setDuration(duration);
            salary.setDayOff(totalDayOff);
            salary.setPrice(totalSalary);
            salaryRepository.save(salary);
        }
    }

    @Override
    public boolean existsSalaryForMonth(int month, int year) {

        LocalDate start = LocalDate.of(year, month, 1);
        LocalDate end = start.withDayOfMonth(start.lengthOfMonth());

        return salaryRepository.existsByDateBetween(start, end);
    }

    @Override
    public List<SalaryDTO> getSalaryByMonth(int month, int year) {

        LocalDate start = LocalDate.of(year, month, 1);
        LocalDate end = start.withDayOfMonth(start.lengthOfMonth());

        List<Salary> salaries = salaryRepository.findByDateBetween(start, end);

        return mapToDTO(salaries);
    }

}
