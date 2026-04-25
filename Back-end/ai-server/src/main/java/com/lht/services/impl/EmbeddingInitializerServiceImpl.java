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

    private static final int BATCH_SIZE = 50;
    private static final int REQUESTS_PER_MINUTE = 80; // an toàn hơn limit 100
    private static final long DELAY_BETWEEN_REQUESTS_MS = 750;
    private static final long DELAY_AFTER_BATCH_MS = 60_000;

    // ========== FOOD ==========

    @Override
    public void initAllFoodEmbeddings() {
        List<Food> foods = foodRepository.findAll().stream().filter(f -> f.getEmbedding() == null).toList();
        processBulk(foods, food -> String.format("%s; energy %.1f kcal per 100g", food.getName(), food.getCalories100g()),
                (food, vector) -> food.setEmbedding(new PGvector(vector)), foodRepository::saveAll
        );
    }

    @Override
    public void createFoodEmbedding(Food food) {
        String text = String.format("%s; energy %.1f kcal per 100g", food.getName(), food.getCalories100g());
        food.setEmbedding(new PGvector(embeddingService.createEmbedding(text)));
        foodRepository.save(food);
    }

    // ========== EXERCISE ==========

    @Override
    public void initAllExerciseEmbeddings() {
        List<Exercise> exercises = exerciseRepository.findAll().stream().filter(e -> e.getEmbedding() == null).toList();
        processBulk(exercises, e -> e.getName() + "; " + String.join("; ", e.getInstructions()),
                (e, vector) -> e.setEmbedding(new PGvector(vector)), exerciseRepository::saveAll
        );
    }

    @Override
    public void createExerciseEmbedding(Exercise exercise) {
        String text = exercise.getName() + "; " + String.join("; ", exercise.getInstructions());
        exercise.setEmbedding(new PGvector(embeddingService.createEmbedding(text)));
        exerciseRepository.save(exercise);
    }

    // ========== BULK PROCESSOR ==========

    private <T> void processBulk(
            List<T> items,
            java.util.function.Function<T, String> textExtractor,
            java.util.function.BiConsumer<T, float[]> vectorSetter,
            java.util.function.Consumer<List<T>> saveAll
    ) {
        List<T> saveBatch = new ArrayList<>();
        int requestCount = 0;

        for (int i = 0; i < items.size(); i++) {
            T item = items.get(i);
            float[] vector = embeddingService.createEmbedding(textExtractor.apply(item));
            vectorSetter.accept(item, vector);
            saveBatch.add(item);
            requestCount++;

            if (saveBatch.size() == BATCH_SIZE) {
                saveAll.accept(saveBatch);
                saveBatch.clear();
            }

            try {
                if (requestCount % REQUESTS_PER_MINUTE == 0) {
                    Thread.sleep(DELAY_AFTER_BATCH_MS);
                } else {
                    Thread.sleep(DELAY_BETWEEN_REQUESTS_MS);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }
    }
}
