package com.lht.controllers.api;

import com.lht.dto.SalaryDTO;
import com.lht.services.SalaryService;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/salaries")
@RequiredArgsConstructor
public class ApiSalaryController {

    private final SalaryService salaryService;

    @GetMapping("/staff/{uuid}")
    public ResponseEntity<List<SalaryDTO>> getSalariesByStaffUuid(@PathVariable("uuid") UUID uuid) {
        List<SalaryDTO> salaries = salaryService.getSalaryByStaffUuid(uuid);
        return ResponseEntity.ok(salaries);
    }

    @GetMapping("/filter")
    public ResponseEntity<List<SalaryDTO>> getSalariesFilter(@RequestParam Map<String, String> params) {
        return ResponseEntity.ok(salaryService.getSalaries(params));
    }

    @GetMapping("/sort")
    public ResponseEntity<Page<SalaryDTO>> getSalariesSort(
            @RequestParam(defaultValue = "date") String sortField,
            @RequestParam(defaultValue = "asc") String sortDir,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        return ResponseEntity.ok(salaryService.getAllSort(sortField, sortDir, page, size));
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<SalaryDTO> getSalaryByUuid(@PathVariable UUID uuid) {
        SalaryDTO salary = salaryService.getSalaryByUuid(uuid);
        if (salary == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(salary);
    }

    @PostMapping
    public ResponseEntity<SalaryDTO> addOrUpdateSalary(@RequestBody SalaryDTO salaryDTO) {
        return ResponseEntity.ok(salaryService.addOrUpdateSalary(salaryDTO));
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> deleteSalary(@PathVariable UUID uuid) {
        if (salaryService.deleteSalary(uuid)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping("/calculate-month")
    public ResponseEntity<String> calculateMonthlySalary(@RequestParam int month, @RequestParam int year) {
        if (salaryService.existsSalaryForMonth(month, year)) {
            return ResponseEntity.ok("Tháng " + month + "/" + year + " đã thanh toán lương.");
        }
        salaryService.calculateMonthlySalaries(month, year);
        return ResponseEntity.ok("Đã tính lương cho tháng " + month + "/" + year + ".");
    }

    @GetMapping("/month")
    public ResponseEntity<List<SalaryDTO>> getSalaryByMonth(
            @RequestParam int month,
            @RequestParam int year) {

        return ResponseEntity.ok(salaryService.getSalaryByMonth(month, year));
    }
}
