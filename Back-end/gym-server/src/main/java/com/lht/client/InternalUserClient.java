package com.lht.client;

import com.lht.dto.InternalUserResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
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

    @GetMapping("/internal/users/{uuid}/role")
    String getRoleByUuid(@PathVariable("uuid") UUID uuid);

    @RequestMapping(value = "/internal/users/{uuid}", method = RequestMethod.HEAD)
    ResponseEntity<Void> existsUser(@PathVariable("uuid") UUID uuid);
    default boolean existsByUuid(UUID uuid) {
        return existsUser(uuid).getStatusCode().is2xxSuccessful();
    }

    @GetMapping("/internal/staffs/{uuid}/type")
    String getStaffType(@PathVariable("uuid") UUID uuid);

    @GetMapping("/internal/staffs")
    List<InternalUserResponse> getAllStaffs();

    @GetMapping("/internal/staffs/fulltime")
    List<UUID> getStaffsFulltime();

    @GetMapping("/internal/staffs/{uuid}/name")
    String getStaffNameByUuid(@PathVariable("uuid") UUID uuid);

    @PostMapping("/internal/staffs/batch")
    Map<UUID, String> getStaffNamesByUuids(@RequestBody Set<UUID> staffUuids);

    @GetMapping("/internal/customers/{uuid}/name")
    String getCustomerNameByUuid(@PathVariable("uuid") UUID uuid);

    @PostMapping("/internal/customers/batch")
    Map<UUID, String> getCustomerNamesByUuids(@RequestBody Set<UUID> customerUuids);

    @PatchMapping("/internal/customers/{uuid}/expiry")
    void updateExpiryAfterPayment(
            @PathVariable("uuid") UUID uuid,
            @RequestParam("planUuid") UUID planUuid
    );
}
