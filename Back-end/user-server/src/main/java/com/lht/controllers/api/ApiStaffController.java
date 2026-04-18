package com.lht.controllers.api;

import com.lht.dto.AvailableStaffDTO;
import com.lht.dto.StaffDTO;
import com.lht.dto.StaffRequestDTO;
import com.lht.services.StaffService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/user/staffs")
@RequiredArgsConstructor
public class ApiStaffController {

    private final StaffService staffService;

    @GetMapping
    public ResponseEntity<?> getStaff() {
        return ResponseEntity.ok(staffService.getStaffs());
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<?> getStaff(@PathVariable UUID uuid) {
        return ResponseEntity.ok(staffService.getStaffByUuid(uuid));
    }

    @PostMapping
    public ResponseEntity<?> createStaff(@ModelAttribute StaffRequestDTO dto,
                                         @RequestPart(value = "image", required = false) MultipartFile file) {
        return ResponseEntity.ok(staffService.createStaff(dto, file));
    }

    @PatchMapping
    public ResponseEntity<?> updateStaff(@ModelAttribute StaffDTO dto,
                                         @RequestPart(value = "image", required = false) MultipartFile file
    ) {
        return ResponseEntity.ok(staffService.updateStaff(dto, file));
    }


    @GetMapping("/working")
    public List<AvailableStaffDTO> getAvailableStaff(
            @RequestParam
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate date,
            @RequestParam
            @DateTimeFormat(iso = DateTimeFormat.ISO.TIME)
            LocalTime checkin,
            @RequestParam
            @DateTimeFormat(iso = DateTimeFormat.ISO.TIME)
            LocalTime checkout
    ) {
        return staffService.getAvailableStaff(date, checkin, checkout);
    }
}
