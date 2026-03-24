package com.lht.services;

import com.lht.pojo.Exercise;
import com.lht.pojo.Food;

import java.util.List;

public interface GeminiService {
    String generateFitnessPlan(double bmi, double calories, List<Food> foods, List<Exercise> exercises, String question);
}
