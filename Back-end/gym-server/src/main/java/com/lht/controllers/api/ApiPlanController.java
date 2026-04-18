package com.lht.controllers.api;

import com.lht.dto.PlanDTO;
import com.lht.pojo.Plan;
import com.lht.services.PlanService;
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
@RequestMapping("/api/v1/gym/plans")
@RequiredArgsConstructor
public class ApiPlanController {

    private final PlanService planService;

    @GetMapping
    public ResponseEntity<List<PlanDTO>> getPlansAll() {
        return ResponseEntity.ok(planService.getAllPlans());
    }

    @GetMapping("/filter")
    public ResponseEntity<List<PlanDTO>> getPlansFilter(@RequestParam Map<String, String> params) {
        return ResponseEntity.ok(planService.getPlans(params));
    }

    @GetMapping("/sort")
    public ResponseEntity<Page<PlanDTO>> getPlansSort(
            @RequestParam(defaultValue = "name") String sortField,
            @RequestParam(defaultValue = "asc") String sortDir,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size) {

        Page<PlanDTO> result = planService.getAllSort(sortField, sortDir, page, size);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<PlanDTO> getPlanByUuid(@PathVariable UUID uuid) {
        PlanDTO plan = planService.getPlanByUuid(uuid);
        if (plan == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(plan);
    }

    @PostMapping
    public ResponseEntity<Plan> addOrUpdatePlan(@RequestBody Plan plan) {
        return ResponseEntity.ok(planService.addOrUpdatePlan(plan));
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> deletePlan(@PathVariable UUID uuid) {
        if (planService.deletePlan(uuid)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
