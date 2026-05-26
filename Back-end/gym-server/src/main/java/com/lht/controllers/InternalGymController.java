package com.lht.controllers;

import com.lht.services.*;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
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
    private final InternalUserService internalUserService;

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

    @GetMapping("/facilities/{facilityUuid}/staffs/available")
    public Set<UUID> getAvailableStaff(
            @PathVariable UUID facilityUuid,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.TIME) LocalTime checkin,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.TIME) LocalTime checkout
    ) {
        return customerScheduleService.getAvailableStaff(facilityUuid, date, checkin, checkout);
    }

    @DeleteMapping("/users/{uuid}")
    public ResponseEntity<Void> deleteRelatedData(
            @PathVariable UUID uuid,
            @RequestParam String role) {
        internalUserService.deleteRelatedData(uuid, role);
        return ResponseEntity.noContent().build();
    }
}
