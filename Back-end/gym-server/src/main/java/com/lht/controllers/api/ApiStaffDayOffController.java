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
@RequestMapping("/api/v1/gym/day-offs")
@RequiredArgsConstructor
public class ApiStaffDayOffController {

    private final StaffDayOffService staffDayOffService;

    @GetMapping
    public ResponseEntity<List<StaffDayOffDTO>> getStaffDayOffs(
            @RequestParam(required = false) Integer month,
            @RequestParam(required = false) Integer year
    ) {
        if (month != null && year != null) {
            return ResponseEntity.ok(staffDayOffService.getStaffDayOffs(month, year));
        }
        return ResponseEntity.ok(staffDayOffService.getStaffDayOffByStaffUuid());
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<StaffDayOffDTO> getStaffDayOffByUuid(@PathVariable UUID uuid) {
        StaffDayOffDTO dto = staffDayOffService.getStaffDayOffByUuid(uuid);
        if (dto == null) return ResponseEntity.notFound().build();

        return ResponseEntity.ok(dto);
    }

    @PostMapping
    public ResponseEntity<StaffDayOffDTO> addOrUpdateStaffDayOff(@RequestBody StaffDayOffDTO dto) {
        return ResponseEntity.ok(staffDayOffService.addOrUpdateStaffDayOff(dto));
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> deleteStaffDayOff(@PathVariable UUID uuid) {
        if (staffDayOffService.deleteStaffDayOff(uuid)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/filter")
    public ResponseEntity<Page<StaffDayOffDTO>> getStaffDayOffsFilter(
            @RequestParam Map<String, String> params,
            @RequestParam(defaultValue = "dateOff") String sortField,
            @RequestParam(defaultValue = "desc") String sortDir,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ResponseEntity.ok(staffDayOffService.getStaffDayOffsFilter(params, sortField, sortDir, page, size));
    }
}
