package com.lht.services.impl;

import com.lht.pojo.Exercise;
import com.lht.pojo.Food;
import com.lht.services.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RagServiceImpl implements RagService {

    private final FoodService foodService;
    private final ExerciseService exerciseService;
    private final GeminiService geminiService;

    @Override
    public String askFitnessAI(double weight, double height, String question) {
        double heightMeter = height / 100.0;
        double bmi = weight / (heightMeter * heightMeter);
        double calories = 2200;
        List<Food> foods = foodService.findFoodsForDiet("healthy high protein low fat food");
        List<Exercise> exercises = exerciseService.findExercisesForWorkout("beginner gym workout");

        return geminiService.generateFitnessPlan(bmi, calories, foods, exercises, question);
    }
}
