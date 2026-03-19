package com.lht.services.impl;

import com.lht.dto.*;
import com.lht.pojo.*;
import com.lht.repositories.*;
import com.lht.services.PlanService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class PlanServiceImpl implements PlanService {

    private final FoodRepository foodRepository;
    private final ExerciseRepository exerciseRepository;

    private final MealDayRepository mealDayRepository;
    private final MealItemRepository mealItemRepository;

    private final WorkoutDayRepository workoutDayRepository;
    private final WorkoutItemRepository workoutItemRepository;

    @Transactional
    public void saveAIPlan(UUID userId, AIPlanDTO plan) {

        List<MealDay> mealDaysToSave = new ArrayList<>();
        List<MealItem> mealItemsToSave = new ArrayList<>();
        List<WorkoutDay> workoutDaysToSave = new ArrayList<>();
        List<WorkoutItem> workoutItemsToSave = new ArrayList<>();

        for (AIDayDTO day : plan.getDays()) {
            MealDay mealDay = MealDay.builder()
                .userUuid(userId)
                .date(day.getDate())
                .build();
            mealDaysToSave.add(mealDay);

            for (AIMealDTO meal : day.getMeals()) {
                MealTypeEnum mealType = MealTypeEnum.valueOf(meal.getType().toUpperCase());
                for (AIMealItemDTO item : meal.getItems()) {
                    MealItem mealItem = MealItem.builder()
                        .mealDay(mealDay)
                        .mealType(mealType)
                        .food(foodRepository.findById(item.getFoodUuid())
                            .orElseThrow(() -> new RuntimeException("Food not found: " + item.getFoodUuid())))
                        .grams((float) item.getGrams())
                        .build();
                    mealItemsToSave.add(mealItem);
                }
            }

            WorkoutDay workoutDay = WorkoutDay.builder()
                .userUuid(userId)
                .date(day.getDate())
                .focusMuscle(MuscleGroupEnum.valueOf(
                    day.getWorkout().getFocusMuscle().toUpperCase()))
                .build();
            workoutDaysToSave.add(workoutDay);

            for (AIExerciseDTO ex : day.getWorkout().getExercises()) {
                WorkoutItem workoutItem = WorkoutItem.builder()
                        .workoutDay(workoutDay)
                        .exercise(exerciseRepository.findById(ex.getExerciseUuid()).orElseThrow(() -> new RuntimeException("Exercise not found: " + ex.getExerciseUuid())))
                        .numberSets(ex.getNumberSets())
                        .numberReps(ex.getNumberReps())
                        .durationMinutes(ex.getDurationMinutes())
                        .build();
                workoutItemsToSave.add(workoutItem);
            }
        }

        // Batch save
        mealDayRepository.saveAll(mealDaysToSave);
        mealItemRepository.saveAll(mealItemsToSave);
        workoutDayRepository.saveAll(workoutDaysToSave);
        workoutItemRepository.saveAll(workoutItemsToSave);
    }
}
