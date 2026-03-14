package com.lht.controllers.api;

import com.lht.dto.StaffDayOffDTO;
import com.lht.services.StaffDayOffService;
import java.util.*;

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
@RequestMapping("/api/v1/day-offs")
@RequiredArgsConstructor
public class ApiStaffDayOffController {

    private final StaffDayOffService staffDayOffService;

    @GetMapping
    public ResponseEntity<List<StaffDayOffDTO>> getAllStaffDayOffs() {
        return ResponseEntity.ok(staffDayOffService.getAllStaffDayOffs());
    }

    @GetMapping("/staff/{uuid}")
    public ResponseEntity<List<StaffDayOffDTO>> getStaffDayOffsByStaffUuid(@PathVariable UUID uuid) {
        return ResponseEntity.ok(staffDayOffService.getStaffDayOffByStaffUuid(uuid));
    }

    @GetMapping("/filter")
    public ResponseEntity<List<StaffDayOffDTO>> getStaffDayOffsFilter(@RequestParam Map<String, String> params) {
        return ResponseEntity.ok(staffDayOffService.getStaffDayOffs(params));
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<StaffDayOffDTO> getStaffDayOffByUuid(@PathVariable UUID uuid) {
        StaffDayOffDTO dto = staffDayOffService.getStaffDayOffByUuid(uuid);
        if (dto == null) return ResponseEntity.notFound().build();

        return ResponseEntity.ok(dto);
    }

    @PostMapping
    public ResponseEntity<StaffDayOffDTO> addOrUpdateStaffDayOff(@RequestBody StaffDayOffDTO dto) {
        StaffDayOffDTO saved = staffDayOffService.addOrUpdateStaffDayOff(dto);
        return ResponseEntity.ok(saved);
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> deleteStaffDayOff(@PathVariable UUID uuid) {
        if (staffDayOffService.deleteStaffDayOff(uuid)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/sort")
    public ResponseEntity<Page<StaffDayOffDTO>> getAllSort(
            @RequestParam(defaultValue = "dateOff") String sortField,
            @RequestParam(defaultValue = "asc") String sortDir,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size) {

        return ResponseEntity.ok(staffDayOffService.getAllSort(sortField, sortDir, page, size));
    }

}
