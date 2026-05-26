package com.lht.controllers.api;

import com.lht.dto.CustomerScheduleDTO;
import com.lht.component.SecurityUtils;
import com.lht.pojo.CustomerSchedule;
import com.lht.services.CustomerScheduleService;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/gym/customer-schedules")
@RequiredArgsConstructor
public class ApiCustomerScheduleController {

    private final CustomerScheduleService customerScheduleService;

    @GetMapping
    public ResponseEntity<List<CustomerScheduleDTO>> getSchedules() {
        List<CustomerScheduleDTO> schedules = customerScheduleService.getSchedulesByAccount();
        return ResponseEntity.ok(schedules);
    }

    @GetMapping("/filter")
    public ResponseEntity<List<CustomerScheduleDTO>> getCustomerSchedulesFilter(@RequestParam Map<String, String> params) {
        UUID uuid = SecurityUtils.getCurrentUserUuid();
        String role = SecurityUtils.getCurrentUserRole();

        if ("CUSTOMER".equals(role)) {
            params.put("customerUuid", uuid.toString());
        } else if ("STAFF".equals(role)) {
            params.put("staffUuid", uuid.toString());
        }

        List<CustomerScheduleDTO> schedules = this.customerScheduleService.getCustomerSchedules(params);
        return ResponseEntity.ok(schedules);
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<CustomerScheduleDTO> getCustomerScheduleByUuid(@PathVariable("uuid") UUID uuid) {
        if (uuid == null) {
            return ResponseEntity.notFound().build();
        }
        CustomerScheduleDTO cs = this.customerScheduleService.getCustomerScheduleByUuid(uuid);
        if (cs == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(cs);
    }

    @PostMapping
    public ResponseEntity<?> addOrUpdateCustomerSchedule(@RequestBody CustomerScheduleDTO dto) {
        if (dto.getStaffUuid() == null ||
                dto.getFacilityUuid() == null ||
                dto.getDate() == null ||
                dto.getCheckin() == null ||
                dto.getCheckout() == null) {
            return ResponseEntity.badRequest().body("Missing required fields");
        }
        boolean conflict = customerScheduleService.isScheduleConflict(dto.getUuid(), dto.getStaffUuid(), dto.getDate(), dto.getCheckin(), dto.getCheckout());
        if (conflict) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Đã có lịch trùng staff + ngày + giờ checkin");
        }
        CustomerSchedule saved = customerScheduleService.addOrUpdateCustomerSchedule(dto);
        return ResponseEntity.ok(saved);
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> deleteCustomerSchedule(@PathVariable("uuid") UUID uuid) {
        if (this.customerScheduleService.deleteCustomerSchedule(uuid)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @PatchMapping("/{uuid}/note")
    public ResponseEntity<?> updateNote(@PathVariable UUID uuid, @RequestBody Map<String, String> body) {
        String note = body.get("note");
        CustomerScheduleDTO updated = customerScheduleService.updateNote(uuid, note);
        if (updated == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(updated);
    }
}