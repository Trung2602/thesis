package com.lht.controllers.api;

import com.lht.component.SecurityUtils;
import com.lht.dto.StaffDayOffDTO;
import com.lht.services.StaffDayOffService;
import java.util.*;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/gym/day-offs")
@RequiredArgsConstructor
public class ApiStaffDayOffController {

    private final StaffDayOffService staffDayOffService;

//    @GetMapping
//    public ResponseEntity<List<StaffDayOffDTO>> getStaffDayOffs(
//            @RequestParam(required = false) Integer month,
//            @RequestParam(required = false) Integer year
//    ) {
//        if (month != null && year != null) {
//            return ResponseEntity.ok(staffDayOffService.getStaffDayOffs(month, year));
//        }
//        return ResponseEntity.ok(staffDayOffService.getStaffDayOffByStaffUuid());
//    }

    @GetMapping
    public ResponseEntity<List<StaffDayOffDTO>> getStaffDayOffs(
            @RequestParam(required = false) Integer month,
            @RequestParam(required = false) Integer year
    ) {
        String role = SecurityUtils.getCurrentUserRole();

        if (month != null && year != null) {
            if ("ADMIN".equals(role)) {
                // Admin xem tất cả staff trong tháng đó
                Map<String, String> params = new HashMap<>();
                params.put("month", month.toString());
                params.put("year", year.toString());
                return ResponseEntity.ok(staffDayOffService.getStaffDayOffsFilter(params, "dateOff", "asc", 0, Integer.MAX_VALUE).getContent());
            }
            return ResponseEntity.ok(staffDayOffService.getStaffDayOffs(month, year));
        }
        return ResponseEntity.badRequest().build();
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<StaffDayOffDTO> getStaffDayOffByUuid(@PathVariable UUID uuid) {
        StaffDayOffDTO dto = staffDayOffService.getStaffDayOffByUuid(uuid);
        if (dto == null) return ResponseEntity.notFound().build();

        return ResponseEntity.ok(dto);
    }

    @PostMapping
    public ResponseEntity<?> addOrUpdateStaffDayOff(@RequestBody StaffDayOffDTO dto) {
        try {
            return ResponseEntity.ok(staffDayOffService.addOrUpdateStaffDayOff(dto));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(e.getMessage());
        }
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

    @PatchMapping("/{uuid}/approve")
    public ResponseEntity<?> approveDayOff(@PathVariable UUID uuid) {
        if (!staffDayOffService.approveDayOff(uuid)) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok().build();
    }
}
