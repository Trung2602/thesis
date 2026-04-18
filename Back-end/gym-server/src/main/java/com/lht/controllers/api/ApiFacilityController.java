package com.lht.controllers.api;

import com.lht.pojo.Facility;
import com.lht.services.FacilityService;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/gym/facilities")
@RequiredArgsConstructor
public class ApiFacilityController {

    private final FacilityService facilityService;

    @GetMapping
    public ResponseEntity<List<Facility>> getFacilitiesAll() {
        return ResponseEntity.ok(facilityService.getAllFacilities());
    }

    @GetMapping("/filter")
    public ResponseEntity<List<Facility>> getFacilitiesFilter(@RequestParam Map<String, String> params) {
        return ResponseEntity.ok(facilityService.getFacilities(params));
    }

    @GetMapping("/sort")
    public ResponseEntity<List<Facility>> getFacilitiesSort(
            @RequestParam(defaultValue = "name") String sortField,
            @RequestParam(defaultValue = "asc") String sortDir) {

        return ResponseEntity.ok(facilityService.getAllSort(sortField, sortDir));
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<Facility> getFacilityByUuid(@PathVariable UUID uuid) {
        Facility facility = facilityService.getFacilityByUuid(uuid);

        if (facility == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(facility);
    }

    @PostMapping
    public ResponseEntity<Facility> addOrUpdateFacility(@RequestBody Facility facility) {
        return ResponseEntity.ok(facilityService.addOrUpdateFacility(facility));
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> deleteFacility(@PathVariable UUID uuid) {

        if (facilityService.deleteFacility(uuid)) {
            return ResponseEntity.noContent().build();
        }

        return ResponseEntity.notFound().build();
    }
}
