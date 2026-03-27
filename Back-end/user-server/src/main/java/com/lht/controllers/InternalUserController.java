package com.lht.controllers;

import com.lht.dto.CustomerBMIDTO;
import com.lht.dto.InternalUserResponse;
import com.lht.services.AccountService;
import com.lht.services.CustomerService;
import com.lht.services.StaffService;
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

    @GetMapping("/users/{uuid}/role")
    public String getRoleByUuid(@PathVariable UUID uuid) {
        return accountService.getRoleByUuid(uuid);
    }

    @RequestMapping(value = "/users/{uuid}", method = RequestMethod.HEAD)
    public ResponseEntity<Void> existsUser(@PathVariable UUID uuid) {
        boolean exists = accountService.existsByUuid(uuid);
        if (exists) {
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

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

    @GetMapping("/staffs/fulltime")
    public List<UUID> getStaffsFulltime() {
        return staffService.getStaffsFulltime();
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

    @PatchMapping("/customers/{uuid}/expiry")
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
}