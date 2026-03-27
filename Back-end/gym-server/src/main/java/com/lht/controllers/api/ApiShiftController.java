package com.lht.controllers.api;

import com.lht.dto.ShiftDTO;
import com.lht.services.ShiftService;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
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
@RequestMapping("/api/v1/shifts")
@RequiredArgsConstructor
public class ApiShiftController {

    private final ShiftService shiftService;

    @GetMapping
    public ResponseEntity<List<ShiftDTO>> getShiftsAll() {
        return ResponseEntity.ok(this.shiftService.getAllShifts());
    }

    @GetMapping("/filter")
    public ResponseEntity<List<ShiftDTO>> getShiftsFilter(@RequestParam Map<String, String> params) {
        return ResponseEntity.ok(this.shiftService.getShifts(params));
    }

    @GetMapping("/sort")
    public ResponseEntity<Page<ShiftDTO>> getShiftsSort(
            @RequestParam(defaultValue = "name") String sortField,
            @RequestParam(defaultValue = "asc") String sortDir,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size) {

        return ResponseEntity.ok(this.shiftService.getAllSort(sortField, sortDir, page, size));
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<ShiftDTO> getShiftByUuid(@PathVariable UUID uuid) {
        ShiftDTO shift = this.shiftService.getShiftByUuid(uuid);

        if (shift == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(shift);
    }

    @PostMapping
    public ResponseEntity<ShiftDTO> addOrUpdateShift(@RequestBody ShiftDTO shiftDTO) {
        return ResponseEntity.ok(this.shiftService.addOrUpdateShift(shiftDTO));
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> deleteShift(@PathVariable UUID uuid) {
        if (this.shiftService.deleteShift(uuid)) {
            return ResponseEntity.noContent().build();
        }

        return ResponseEntity.notFound().build();
    }
}
