package com.lht.controllers.api;

import com.lht.dto.AdminDTO;
import com.lht.dto.AdminRequestDTO;
import com.lht.dto.CustomerRequestDTO;
import com.lht.dto.StaffDTO;
import com.lht.services.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/user/admins")
@RequiredArgsConstructor
public class ApiAdminController {
    private final AdminService adminService;

    @GetMapping("/{uuid}")
    public ResponseEntity<?> getAdmin(@PathVariable UUID uuid) {
        return ResponseEntity.ok(adminService.getAdminById(uuid));
    }

    @PostMapping
    public ResponseEntity<?> createAdmin(@RequestBody AdminRequestDTO dto) {
        return ResponseEntity.ok(adminService.createAdmin(dto));
    }
    @PatchMapping
    public ResponseEntity<?> updateAdmin(@RequestBody AdminRequestDTO dto) {
        return ResponseEntity.ok(adminService.updateAdmin(dto));
    }
}
