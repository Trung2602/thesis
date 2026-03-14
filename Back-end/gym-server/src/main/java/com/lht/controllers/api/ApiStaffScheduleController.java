package com.lht.controllers.api;

import com.lht.dto.StaffScheduleDTO;
import com.lht.services.StaffScheduleService;
import java.util.*;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
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
@RequestMapping("/api/v1/staff-schedules")
@RequiredArgsConstructor
public class ApiStaffScheduleController {

    private final StaffScheduleService staffScheduleService;

    @GetMapping("/staff/{staffUuid}")
    public ResponseEntity<List<StaffScheduleDTO>> getByStaffUuid(@PathVariable UUID staffUuid) {
        return ResponseEntity.ok(staffScheduleService.getStaffScheduleByStaffUuid(staffUuid));
    }

    @GetMapping("/filter")
    public ResponseEntity<List<StaffScheduleDTO>> filter(@RequestParam Map<String, String> params) {
        return ResponseEntity.ok(staffScheduleService.getStaffSchedules(params));
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<StaffScheduleDTO> getByUuid(@PathVariable UUID uuid) {
        StaffScheduleDTO dto = staffScheduleService.getStaffScheduleByUuid(uuid);
        if (dto == null) return ResponseEntity.notFound().build();

        return ResponseEntity.ok(dto);
    }

    @PostMapping
    public ResponseEntity<?> addOrUpdateStaffSchedule(@RequestBody StaffScheduleDTO dto) {
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
