package com.lht.client;

import com.lht.dto.InternalUserResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@FeignClient(
        name = "user-service",
        url = "${user.service.url}"
)
public interface InternalUserClient {

    @GetMapping("/internal/users/get-role-uuid")
    String getRoleByUuid(@RequestParam("uuid") UUID uuid);

    @GetMapping("/internal/users/exists-uuid")
    boolean existsByUuid(@RequestParam("uuid") UUID uuid);

    @GetMapping("/internal/users/staff-type")
    String getStaffType(@RequestParam("uuid") UUID uuid);

    @GetMapping("/internal/users/info-mail")
    InternalUserResponse getInternalByMail(@RequestParam("mail") String mail);

    @GetMapping("/internal/users/info-uuid")
    InternalUserResponse getInternalByUuid(@RequestParam("uuid") UUID uuid);

    @GetMapping("/internal/staffs")
    List<InternalUserResponse> getAllStaffs();

    @GetMapping("/internal/staffs/fulltime")
    List<UUID> getStaffsFulltime();

    @GetMapping("/internal/staff/name")
    String getStaffNameByUuid(@RequestParam("uuid") UUID uuid);

    @PostMapping("/internal/staff-by-uuids")
    Map<UUID, String> getStaffNamesByUuids(@RequestBody Set<UUID> staffUuids);

    @GetMapping("/internal/customer/name")
    String getCustomerNameByUuid(@RequestParam("uuid") UUID uuid);

    @PostMapping("/internal/customer-by-uuids")
    Map<UUID, String> getCustomerNamesByUuids(@RequestBody Set<UUID> customerUuids);

    @PostMapping("/internal/update-expiry-after-payment")
    void updateExpiryAfterPayment(
            @RequestParam("customerUuid") UUID customerUuid,
            @RequestParam("planUuid") UUID planUuid
    );
}
