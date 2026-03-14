package com.lht.controllers.api;

import com.lht.client.InternalUserClient;
import com.lht.dto.CustomerScheduleDTO;
import com.lht.pojo.CustomerSchedule;
import com.lht.services.CustomerScheduleService;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/customer-schedules")
@RequiredArgsConstructor
public class ApiCustomerScheduleController {

    private final CustomerScheduleService customerScheduleService;
    private final InternalUserClient internalUserClient;

    @GetMapping("/customer/{uuid}") //lấy theo custotmerUuid
    public ResponseEntity<List<CustomerScheduleDTO>> getCustomerSchedulesCustomer(@PathVariable("uuid") UUID uuid) {
        List<CustomerScheduleDTO> schedules = customerScheduleService.getCustomerSchedulesByCustomerUuid(uuid);
        return ResponseEntity.ok(schedules);
    }

    @GetMapping("/staff/{uuid}") //lấy theo staffUuid
    public ResponseEntity<List<CustomerScheduleDTO>> getCustomerSchedulesStaff(@PathVariable("uuid") UUID uuid) {
        List<CustomerScheduleDTO> schedules = customerScheduleService.getCustomerSchedulesByStaffUuid(uuid);
        return ResponseEntity.ok(schedules);
    }

    @GetMapping("/account/{uuid}") //lấy theo accountUuid
    public ResponseEntity<List<CustomerScheduleDTO>> getCustomerScheduleAll(@PathVariable("uuid") UUID uuid) {
        List<CustomerScheduleDTO> schedules;
        if (("Customer").equals(internalUserClient.getRoleByUuid(uuid))) {
            schedules = customerScheduleService.getCustomerSchedulesByCustomerUuid(uuid);
        } else {
            schedules = customerScheduleService.getCustomerSchedulesByStaffUuid(uuid);
        }
        return ResponseEntity.ok(schedules);
    }

    @GetMapping("/filter")
    public ResponseEntity<List<CustomerScheduleDTO>> getCustomerSchedulesFilter(@RequestParam Map<String, String> params) {

        // Lấy accountUuid từ params
        String accountUuid = params.get("accountUuid");
        if (accountUuid == null) {
            return ResponseEntity.badRequest().build();
        }

        UUID uuid = UUID.fromString(accountUuid);
        String role = internalUserClient.getRoleByUuid(uuid);

        if ("Customer".equals(role)) {
            params.put("customerUuid", accountUuid);
        } else if ("Staff".equals(role)) {
            params.put("staffUuid", accountUuid);
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
        if (dto.getCustomerUuid() == null ||
                dto.getStaffUuid() == null ||
                dto.getFacilityUuid() == null ||
                dto.getDate() == null ||
                dto.getCheckin() == null) {
            return ResponseEntity.badRequest().body("Missing required fields");
        }

        CustomerSchedule cs = new CustomerSchedule();
        cs.setUuid(dto.getUuid());
        cs.setDate(dto.getDate());
        cs.setCheckin(dto.getCheckin());
        cs.setCheckout(dto.getCheckout());
        cs.setCustomerUuid(dto.getCustomerUuid());
        cs.setStaffUuid(dto.getStaffUuid());
        cs.setFacilityUuid(dto.getFacilityUuid());

        boolean conflict = customerScheduleService.isScheduleConflict(dto.getUuid(), dto.getStaffUuid(), dto.getDate(), dto.getCheckin());
        if (conflict) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body("Đã có lịch trùng staff + ngày + giờ checkin");
        }

        CustomerSchedule saved = customerScheduleService.addOrUpdateCustomerSchedule(cs);
        return ResponseEntity.ok(saved);
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> deleteCustomerSchedule(@PathVariable("uuid") UUID uuid) {
        if (this.customerScheduleService.deleteCustomerSchedule(uuid)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}