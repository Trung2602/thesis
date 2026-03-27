package com.lht.controllers;

import com.lht.services.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/internal")
@RequiredArgsConstructor
public class InternalGymController {

    private final PlanService planService;
    private final FacilityService facilityService;
    private final CustomerScheduleService customerScheduleService;

    @GetMapping("/plans/{uuid}/duration")
    public int getDurationDays(@PathVariable UUID uuid) {
        return planService.getDurationDays(uuid);
    }

    @GetMapping("/facilities/{uuid}/name")
    public String getFacilityNameByUuid(@PathVariable UUID uuid) {
        return facilityService.getFacilityByUuid(uuid).getName();
    }

    @PostMapping("/facilities/batch")
    public Map<UUID, String> getFacilityNamesByUuids(@RequestBody Set<UUID> facilityUuids) {
        return facilityService.getFacilityNamesByUuids(facilityUuids);
    }

    @GetMapping("/staffs")
    public Set<UUID> getAvailableStaff(
            @RequestParam LocalDate date,
            @RequestParam LocalTime checkIn,
            @RequestParam LocalTime checkOut
    ) {
        return customerScheduleService.getAvailableStaff(date, checkIn, checkOut);
    }
}
