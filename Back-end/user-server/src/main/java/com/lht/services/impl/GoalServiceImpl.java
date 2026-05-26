package com.lht.services.impl;

import com.lht.dto.GoalDTO;
import com.lht.pojo.Goal;
import com.lht.repositories.GoalRepository;
import com.lht.services.GoalService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@Transactional
@RequiredArgsConstructor
public class GoalServiceImpl implements GoalService {

    private final GoalRepository goalRepository;

    private GoalDTO toDTO(Goal e) {
        return GoalDTO.builder()
                .uuid(e.getUuid())
                .customerUuid(e.getCustomerUuid())
                .goalType(e.getGoalType())
                .targetWeight(e.getTargetWeight())
                .targetBodyFat(e.getTargetBodyFat())
                .deadline(e.getDeadline())
                .isAchieved(e.getIsAchieved())
                .build();
    }

    @Override
    public GoalDTO getCurrentGoal(UUID customerUuid) {
        return goalRepository.findByCustomerUuid(customerUuid)
                .map(this::toDTO).orElse(null);
    }

    @Override
    public GoalDTO create(UUID customerUuid, GoalDTO dto) {
        Optional<Goal> existing = goalRepository.findByCustomerUuid(customerUuid);
        Goal goal = existing.orElse(new Goal());
        goal.setCustomerUuid(customerUuid);
        goal.setGoalType(dto.getGoalType());
        goal.setTargetWeight(dto.getTargetWeight());
        goal.setTargetBodyFat(dto.getTargetBodyFat());
        goal.setDeadline(dto.getDeadline());
        goal.setIsAchieved(false);
        return toDTO(goalRepository.save(goal));
    }

    @Override
    public GoalDTO update(UUID uuid, GoalDTO dto) {
        Goal goal = goalRepository.findById(uuid).orElseThrow(() -> new RuntimeException("Goal not found: " + uuid));
        goal.setGoalType(dto.getGoalType());
        goal.setTargetWeight(dto.getTargetWeight());
        goal.setTargetBodyFat(dto.getTargetBodyFat());
        goal.setDeadline(dto.getDeadline());
        return toDTO(goalRepository.save(goal));
    }

    @Override
    public GoalDTO markAchieved(UUID uuid) {
        Goal goal = goalRepository.findById(uuid).orElseThrow(() -> new RuntimeException("Goal not found: " + uuid));
        goal.setIsAchieved(true);
        return toDTO(goalRepository.save(goal));
    }

    @Override
    public void delete(UUID uuid) {
        if (!goalRepository.existsById(uuid))
            throw new RuntimeException("Goal not found: " + uuid);
        goalRepository.deleteById(uuid);
    }
}