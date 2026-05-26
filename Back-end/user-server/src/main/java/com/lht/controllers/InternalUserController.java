package com.lht.controllers;

import com.lht.dto.BodyLogDTO;
import com.lht.dto.CustomerBMIDTO;
import com.lht.dto.GoalDTO;
import com.lht.dto.InternalUserResponse;
import com.lht.services.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/internal")
@RequiredArgsConstructor
public class InternalUserController {

    private final AccountService accountService;
    private final StaffService staffService;
    private final CustomerService customerService;
    private final BodyLogService bodyLogService;
    private final GoalService goalService;

    @GetMapping("/staffs/{uuid}/type")
    public String getStaffType(@PathVariable UUID uuid) {
        return staffService.getStaffType(uuid);
    }

    @GetMapping("/users")
    public InternalUserResponse getInternalByMail(@RequestParam String mail) {
        return accountService.getInternalUserByMail(mail);
    }

    @GetMapping("/users/{uuid}")
    public InternalUserResponse getInternalByUuid(@PathVariable UUID uuid) {
        return accountService.getInternalUserByUuid(uuid);
    }

    @GetMapping("/staffs")
    public List<InternalUserResponse> getAllStaffs() {
        return staffService.getStaffsAll();
    }


    @GetMapping("/staffs/{uuid}/name")
    public String getStaffNameByUuid(@PathVariable UUID uuid) {
        return staffService.getStaffNameByUuid(uuid);
    }

    @PostMapping("/staffs/batch")
    public Map<UUID, String> getStaffNamesByUuids(@RequestBody Set<UUID> staffUuids) {
        return staffService.getStaffNamesByUuids(staffUuids);
    }

    @GetMapping("/customers/{uuid}/name")
    public String getCustomerNameByUuid(@PathVariable UUID uuid) {
        return customerService.getCustomerNameByUuid(uuid);
    }

    @PostMapping("/customers/batch")
    public Map<UUID, String> getCustomerNamesByUuids(@RequestBody Set<UUID> customerUuids) {
        return customerService.getCustomerNamesByUuids(customerUuids);
    }

    @PostMapping("/customers/{uuid}/expiry")
    public void updateExpiryAfterPayment(
            @PathVariable UUID uuid,
            @RequestParam UUID planUuid)
    {
        customerService.updateExpiryAfterPayment(uuid, planUuid);
    }

    @GetMapping("/customers/{uuid}/bmi")
    public CustomerBMIDTO getBMICustomer(@PathVariable UUID uuid) {
        return customerService.getBMI(uuid);
    }

    @GetMapping("/staff/{uuid}/facility")
    public UUID getFacilityUuidbyStaffUuid(@PathVariable UUID uuid){return staffService.getFacilityUuidByStaffUuid(uuid);}

    @GetMapping("/customer/{uuid}/body-log")
    public ResponseEntity<List<BodyLogDTO>> getRecentHistory(@PathVariable UUID uuid,
                                                             @RequestParam(defaultValue = "3") int limit) {
        return ResponseEntity.ok(bodyLogService.getRecentHistory(uuid, limit));
    }

    @GetMapping("/customer/{uuid}/goal")
    public ResponseEntity<GoalDTO> getGoalByCustomerUuid(@PathVariable UUID uuid) {
        return ResponseEntity.ok(goalService.getCurrentGoal(uuid));
    }
}