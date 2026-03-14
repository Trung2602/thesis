package com.lht.controllers;

import com.lht.services.*;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

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

    @GetMapping("/plans/duration")
    public int getDurationDays(@RequestParam UUID planUuid) {
        return planService.getDurationDays(planUuid);
    }

    @GetMapping("/facility/name")
    public String getFacilityNameByUuid(@RequestParam("uuid") UUID uuid) {
        return facilityService.getFacilityByUuid(uuid).getName();
    }

    @PostMapping("/facility-by-uuids")
    public Map<UUID, String> getFacilityNamesByUuids(@RequestBody Set<UUID> facilityUuids) {
        return facilityService.getFacilityNamesByUuids(facilityUuids);
    }

    @GetMapping("/staffs/available")
    public Set<UUID> getAvailableStaff(
            @RequestParam LocalDate date,
            @RequestParam LocalTime checkIn,
            @RequestParam LocalTime checkOut
    ) {
        return customerScheduleService.getAvailableStaff(date, checkIn, checkOut);
    }
}
