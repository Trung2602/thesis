package com.lht.services;

import com.lht.dto.AIPlanDTO;

import java.util.UUID;

public interface PlanService {
    void saveAIPlan(UUID userId, AIPlanDTO plan);
}
