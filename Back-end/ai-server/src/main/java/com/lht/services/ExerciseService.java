package com.lht.services;

import com.lht.dto.ExerciseDTO;
import com.lht.pojo.Exercise;
import org.springframework.data.domain.Page;

import java.util.List;
import java.util.UUID;

public interface ExerciseService {
    Page<ExerciseDTO> getExercises(int page, int size);
    ExerciseDTO getExerciseById(UUID uuid);
    ExerciseDTO createExercise(ExerciseDTO exerciseDTO);
    ExerciseDTO updateExercise(ExerciseDTO exerciseDTO);
    void deleteExercise(UUID uuid);
    List<Exercise> findTopSimilar(float[] queryVector, int k);
}