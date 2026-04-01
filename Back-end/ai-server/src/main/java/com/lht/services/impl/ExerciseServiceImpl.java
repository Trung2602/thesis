package com.lht.services.impl;

import com.lht.pojo.Exercise;
import com.lht.repositories.ExerciseRepository;
import com.lht.services.EmbeddingService;
import com.lht.services.ExerciseService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ExerciseServiceImpl implements ExerciseService {

    private final ExerciseRepository exerciseRepository;

    @Override
    public List<Exercise> findTopSimilar(float[] queryVector, int k) {
        String vector = Arrays.toString(queryVector);
        return exerciseRepository.findTopSimilar(vector, k);
    }
}
