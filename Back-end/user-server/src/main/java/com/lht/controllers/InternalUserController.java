package com.lht.controllers;

import com.lht.dto.CustomerBMIDTO;
import com.lht.dto.InternalUserResponse;
import com.lht.services.AccountService;
import com.lht.services.CustomerService;
import com.lht.services.StaffService;
import lombok.RequiredArgsConstructor;
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

    @GetMapping("/users/get-role-uuid")
    public String getRoleByUuid(@RequestParam UUID uuid) {
        return accountService.getRoleByUuid(uuid);
    }

    @GetMapping("/users/exists-uuid")
    public boolean existsByUuid(@RequestParam UUID uuid) {

        return accountService.existsByUuid(uuid);
    }

    @GetMapping("/users/staff-type")
    public String getStaffType(@RequestParam UUID uuid) {

        return staffService.getStaffType(uuid);
    }

    @GetMapping("/users/info-mail")
    public InternalUserResponse getInternalByMail(@RequestParam String mail) {
        return accountService.getInternalUserByMail(mail);
    }

    @GetMapping("/users/info-uuid")
    public InternalUserResponse getInternalByUuid(@RequestParam UUID uuid) {
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

    @GetMapping("/staff/name")
    public String getStaffNameByUuid(@RequestParam UUID uuid) {
        return staffService.getStaffNameByUuid(uuid);
    }

    @PostMapping("/staff-by-uuids")
    public Map<UUID, String> getStaffNamesByUuids(@RequestBody Set<UUID> staffUuids) {
        return staffService.getStaffNamesByUuids(staffUuids);
    }

    @GetMapping("/customer/name")
    public String getCustomerNameByUuid(@RequestParam UUID uuid) {
        return customerService.getCustomerNameByUuid(uuid);
    }

    @PostMapping("/customer-by-uuids")
    public Map<UUID, String> getCustomerNamesByUuids(@RequestBody Set<UUID> customerUuids) {
        return customerService.getCustomerNamesByUuids(customerUuids);
    }

    @PostMapping("/update-expiry-after-payment")
    public void updateExpiryAfterPayment(
            @RequestParam UUID customerUuid,
            @RequestParam UUID planUuid)
    {
        customerService.updateExpiryAfterPayment(customerUuid, planUuid);
    }

    @GetMapping("/customers/{uuid}/BMI")
    public CustomerBMIDTO getBMICustomer(@PathVariable UUID uuid) {
        return customerService.getBMI(uuid);
    }
}