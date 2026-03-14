package com.lht.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

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

    @GetMapping("/internal/plans/duration")
    int getDurationDays(@RequestParam("planUuid") UUID planUuid);

    @GetMapping("/internal/facility/name")
    String getFacilityNameByUuid(@RequestParam("uuid") UUID uuid);

    @PostMapping("/internal/facility-by-uuids")
    Map<UUID, String> getFacilityNamesByUuids(@RequestBody Set<UUID> facilityUuids);

    @GetMapping("/internal/staffs/available")
    Set<UUID> getAvailableStaff(
            @RequestParam("date") LocalDate date,
            @RequestParam("checkIn") LocalTime checkIn,
            @RequestParam("checkOut") LocalTime checkOut
    );
}
