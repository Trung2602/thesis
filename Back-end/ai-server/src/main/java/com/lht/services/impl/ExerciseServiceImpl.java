package com.lht.services.impl;

import com.lht.pojo.Exercise;
import com.lht.repositories.ExerciseRepository;
import com.lht.services.EmbeddingService;
import com.lht.services.ExerciseService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ExerciseServiceImpl implements ExerciseService {

    private final ExerciseRepository exerciseRepository;
    private final EmbeddingService embeddingService;

    @Override
    public List<Exercise> findExercisesForWorkout(String query) {

        String embedding = embeddingService.createEmbedding(query);

        return exerciseRepository.searchByEmbedding(embedding, 20);
    }
}
