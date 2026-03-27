package com.lht.client;

import org.springframework.cloud.openfeign.FeignClient;
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

    @GetMapping("/internal/staffs")
    Set<UUID> getAvailableStaff(
            @RequestParam("date") LocalDate date,
            @RequestParam("checkIn") LocalTime checkIn,
            @RequestParam("checkOut") LocalTime checkOut
    );
}
