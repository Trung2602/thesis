package com.lht.services.impl;

import com.lht.pojo.Exercise;
import com.lht.pojo.Food;
import com.lht.repositories.ExerciseRepository;
import com.lht.repositories.FoodRepository;
import com.lht.services.EmbeddingInitializerService;
import com.lht.services.EmbeddingService;
import com.pgvector.PGvector;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class EmbeddingInitializerServiceImpl implements EmbeddingInitializerService {

    private final EmbeddingService embeddingService;
    private final FoodRepository foodRepository;
    private final ExerciseRepository exerciseRepository;

    private static final int batchSize = 50;

    @Override
    public void initFoodEmbedding() {
        List<Food> batch = new ArrayList<>();
        for (Food food : foodRepository.findAll()) {
            if (food.getEmbedding() != null) continue;
            float[] vector = embeddingService.createEmbedding(food.getName());
            food.setEmbedding(new PGvector(vector));
            batch.add(food);
            if (batch.size() == batchSize) {
                foodRepository.saveAll(batch);
                batch.clear();
            }
        }
        if (!batch.isEmpty()) foodRepository.saveAll(batch);
    }

    @Override
    public void initExerciseEmbedding() {
        List<Exercise> batch = new ArrayList<>();
        for (Exercise e : exerciseRepository.findAll()) {
            if (e.getEmbedding() != null) continue;
            String text = e.getName() + "; " + String.join("; ", e.getInstructions());
            float[] vector = embeddingService.createEmbedding(text);
            e.setEmbedding(new PGvector(vector));
            batch.add(e);
            if (batch.size() == batchSize) {
                exerciseRepository.saveAll(batch);
                batch.clear();
            }
        }
        if (!batch.isEmpty()) exerciseRepository.saveAll(batch);
    }
}
