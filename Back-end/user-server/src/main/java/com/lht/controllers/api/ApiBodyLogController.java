package com.lht.controllers.api;

import com.lht.component.SecurityUtils;
import com.lht.dto.BodyLogDTO;
import com.lht.services.BodyLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/user/body-log")
@RequiredArgsConstructor
public class ApiBodyLogController {

    private final BodyLogService bodyLogService;

    @GetMapping("/customer/{uuid}")
    public ResponseEntity<List<BodyLogDTO>> getMyHistory(@PathVariable UUID uuid) {
        return ResponseEntity.ok(bodyLogService.getHistory(uuid));
    }

    @PostMapping
    public ResponseEntity<BodyLogDTO> create(@RequestBody BodyLogDTO dto) {
        if (dto.getCustomerUuid() == null) throw new RuntimeException("customerUuid không được để trống");
        UUID staffUuid = SecurityUtils.getCurrentUserUuid();
        dto.setStaffUuid(staffUuid);
        return ResponseEntity.ok(bodyLogService.create(dto));
    }

    @PatchMapping("/{uuid}")
    public ResponseEntity<BodyLogDTO> update(@PathVariable UUID uuid,
                                             @RequestBody BodyLogDTO dto) {
        return ResponseEntity.ok(bodyLogService.update(uuid, dto));
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> delete(@PathVariable UUID uuid) {
        bodyLogService.delete(uuid);
        return ResponseEntity.noContent().build();
    }
}
