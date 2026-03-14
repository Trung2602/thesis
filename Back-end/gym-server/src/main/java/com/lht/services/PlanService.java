package com.lht.services;

import com.lht.dto.PlanDTO;
import com.lht.pojo.Plan;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;

public interface PlanService {

    List<PlanDTO> getAllPlans();

    PlanDTO getPlanByUuid(UUID uuid);

    Plan getByUuid(UUID uuid);

    Plan addOrUpdatePlan(Plan p);

    boolean deletePlan(UUID uuid);

    List<PlanDTO> getPlans(Map<String, String> params);

    Page<PlanDTO> getAllSort(String sortField, String sortDir, int page, int size);

    Integer getDurationDays(UUID uuid);
}
