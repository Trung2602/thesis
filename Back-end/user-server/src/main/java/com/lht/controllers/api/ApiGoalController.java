package com.lht.controllers.api;

import com.lht.component.SecurityUtils;
import com.lht.dto.GoalDTO;
import com.lht.services.GoalService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/user/goal")
@RequiredArgsConstructor
public class ApiGoalController {

    private final GoalService goalService;
    @GetMapping
    public ResponseEntity<GoalDTO> getCurrent() {
        UUID uuid = SecurityUtils.getCurrentUserUuid();
        return ResponseEntity.ok(goalService.getCurrentGoal(uuid));
    }

    @PostMapping
    public ResponseEntity<GoalDTO> create(@RequestBody GoalDTO dto) {
        UUID uuid = SecurityUtils.getCurrentUserUuid();
        return ResponseEntity.ok(goalService.create(uuid, dto));
    }

    @PutMapping("/{uuid}")
    public ResponseEntity<GoalDTO> update(@PathVariable UUID uuid,
                                          @RequestBody GoalDTO dto) {
        return ResponseEntity.ok(goalService.update(uuid, dto));
    }

    @PatchMapping("/{uuid}/achieve")
    public ResponseEntity<GoalDTO> markAchieved(@PathVariable UUID uuid) {
        return ResponseEntity.ok(goalService.markAchieved(uuid));
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> delete(@PathVariable UUID uuid) {
        goalService.delete(uuid);
        return ResponseEntity.noContent().build();
    }
}
