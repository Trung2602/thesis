package com.lht.services;

import com.lht.dto.GoalDTO;
import java.util.List;
import java.util.UUID;

public interface GoalService {
    GoalDTO getCurrentGoal(UUID customerUuid);
    GoalDTO create(UUID customerUuid, GoalDTO dto);
    GoalDTO update(UUID uuid, GoalDTO dto);
    GoalDTO markAchieved(UUID uuid);
    void delete(UUID uuid);
}