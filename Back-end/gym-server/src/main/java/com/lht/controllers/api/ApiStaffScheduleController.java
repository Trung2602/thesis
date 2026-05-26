package com.lht.controllers.api;

import com.lht.dto.StaffScheduleDTO;
import com.lht.component.SecurityUtils;
import com.lht.services.StaffScheduleService;
import java.util.*;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/gym/staff-schedules")
@RequiredArgsConstructor
public class ApiStaffScheduleController {

    private final StaffScheduleService staffScheduleService;

    @GetMapping
    public ResponseEntity<List<StaffScheduleDTO>> getStaffSchedule() {
        return ResponseEntity.ok(staffScheduleService.getAllStaffSchedules());
    }

    @GetMapping("/staff")
    public ResponseEntity<List<StaffScheduleDTO>> getByStaffUuid() {
        return ResponseEntity.ok(staffScheduleService.getStaffScheduleByStaffUuid());
    }

    @GetMapping("/filter")
    public ResponseEntity<List<StaffScheduleDTO>> filter(@RequestParam Map<String, String> params) {
        return ResponseEntity.ok(staffScheduleService.getStaffSchedules(params));
    }

    @PatchMapping("/{uuid}/approve")
    public ResponseEntity<StaffScheduleDTO> approve(@PathVariable UUID uuid) {
        return ResponseEntity.ok(staffScheduleService.approveSchedule(uuid));
    }

    @GetMapping("/filter/staff")
    public ResponseEntity<List<StaffScheduleDTO>> filterByStaffUuid(@RequestParam Map<String, String> params) {
        return ResponseEntity.ok(staffScheduleService.getStaffSchedulesByStaffUuid(params));
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<StaffScheduleDTO> getByUuid(@PathVariable UUID uuid) {
        StaffScheduleDTO dto = staffScheduleService.getStaffScheduleByUuid(uuid);
        if (dto == null) return ResponseEntity.notFound().build();

        return ResponseEntity.ok(dto);
    }

    @PostMapping
    public ResponseEntity<?> addOrUpdateStaffSchedule(@RequestBody StaffScheduleDTO dto) {
        if (dto.getStaffUuid() == null) return ResponseEntity.badRequest().body("Staff UUID is required");
        if (dto.getShiftUuid() == null) return ResponseEntity.badRequest().body("Shift UUID is required");
        if (dto.getDate() == null) return ResponseEntity.badRequest().body("Date is required");
        try {
            StaffScheduleDTO saved = staffScheduleService.addOrUpdateStaffSchedule(dto);
            return ResponseEntity.ok(saved);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMessage());
        }
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> deleteStaffSchedule(@PathVariable UUID uuid) {
        boolean deleted = staffScheduleService.deleteStaffSchedule(uuid);
        if (deleted) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/page")
    public ResponseEntity<Page<StaffScheduleDTO>> getPage(
            @RequestParam(defaultValue = "date") String sortField,
            @RequestParam(defaultValue = "asc") String sortDir,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        return ResponseEntity.ok(staffScheduleService.getAllSort(sortField, sortDir, page, size));
    }
}
