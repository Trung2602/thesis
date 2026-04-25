package com.lht.services;

import com.lht.pojo.Exercise;
import com.lht.pojo.Food;

public interface EmbeddingInitializerService {
    void initAllFoodEmbeddings();
    void createFoodEmbedding(Food food);
    void initAllExerciseEmbeddings();
    void createExerciseEmbedding(Exercise exercise);
}
