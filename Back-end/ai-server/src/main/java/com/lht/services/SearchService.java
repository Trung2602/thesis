package com.lht.services;

import com.lht.dto.RAGContext;
import com.lht.pojo.Exercise;
import com.lht.pojo.Food;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SearchService {

    private final FoodService foodService;
    private final ExerciseService exerciseService;

    public RAGContext research(float[] queryVector) {
        List<Food> foods = foodService.findTopSimilar(queryVector, 5);
        List<Exercise> exercises = exerciseService.findTopSimilar(queryVector, 5);
        return new RAGContext(foods, exercises);
    }
}
