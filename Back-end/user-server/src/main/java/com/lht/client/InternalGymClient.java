package com.lht.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@FeignClient(
        name = "gym-service",
        url = "${gym.service.url}"
)
public interface InternalGymClient {

    @GetMapping("/internal/plans/{uuid}/duration")
    int getDurationDays(@PathVariable("uuid") UUID uuid);

    @GetMapping("/internal/facilities/{uuid}/name")
    String getFacilityNameByUuid(@PathVariable("uuid") UUID uuid);

    @PostMapping("/internal/facilities/batch")
    Map<UUID, String> getFacilityNamesByUuids(@RequestBody Set<UUID> facilityUuids);

    @GetMapping("/internal/facilities/{facilityUuid}/staffs/available")
    Set<UUID> getAvailableStaff(
            @PathVariable UUID facilityUuid,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam("checkin") @DateTimeFormat(iso = DateTimeFormat.ISO.TIME) LocalTime checkin,
            @RequestParam("checkout") @DateTimeFormat(iso = DateTimeFormat.ISO.TIME) LocalTime checkout
    );

    @DeleteMapping("/internal/users/{uuid}")
    void deleteRelatedData(
            @PathVariable UUID uuid,
            @RequestParam String role
    );
}
