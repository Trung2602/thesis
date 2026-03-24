package com.lht.services.impl;

import com.lht.client.InternalUserClient;
import com.lht.dto.CustomerDTO;
import com.lht.pojo.Exercise;
import com.lht.pojo.Food;
import com.lht.services.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RagServiceImpl implements RagService {

    private final FoodService foodService;
    private final ExerciseService exerciseService;
    private final GeminiService geminiService;
    private final InternalUserClient internalUserClient;

    @Override
    public String askFitnessAI(UUID userUuid, String question) {
        CustomerDTO user = internalUserClient.getCustomer(userUuid);
        double weight = user.getWeight().doubleValue();
        double height = user.getHeight().doubleValue();
        double heightMeter = height / 100.0;
        double bmi = weight / (heightMeter * heightMeter);
        double calories = 2200;
        List<Food> foods = foodService.findFoodsForDiet("healthy high protein low fat food");
        List<Exercise> exercises = exerciseService.findExercisesForWorkout("beginner gym workout");
        return geminiService.generateFitnessPlan(bmi, calories, foods, exercises, question);
    }
}
