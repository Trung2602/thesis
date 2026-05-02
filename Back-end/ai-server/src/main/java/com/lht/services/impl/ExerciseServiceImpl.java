package com.lht.services.impl;

import com.lht.dto.ExerciseDTO;
import com.lht.pojo.Exercise;
import com.lht.repositories.ExerciseRepository;
import com.lht.services.EmbeddingService;
import com.lht.services.ExerciseService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ExerciseServiceImpl implements ExerciseService {

    private final ExerciseRepository exerciseRepository;

    private ExerciseDTO toDTO(Exercise exercise) {
        ExerciseDTO dto = new ExerciseDTO();
        dto.setUuid(exercise.getUuid());
        dto.setName(exercise.getName());
        dto.setForce(exercise.getForce());
        dto.setDifficulty(exercise.getDifficulty());
        dto.setMechanic(exercise.getMechanic());
        dto.setEquipment(exercise.getEquipment());
        dto.setPrimaryMuscles(exercise.getPrimaryMuscles());
        dto.setSecondaryMuscles(exercise.getSecondaryMuscles());
        dto.setInstructions(exercise.getInstructions());
        dto.setImages(exercise.getImages());
        dto.setCategory(exercise.getCategory());
        return dto;
    }

    @Override
    public ExerciseDTO getExerciseById(UUID uuid) {
        Exercise exercise = exerciseRepository.findById(uuid).orElseThrow(() -> new RuntimeException("Exercise not found with uuid"));
        return toDTO(exercise);
    }

    @Override
    public Page<ExerciseDTO> getExercises(int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return exerciseRepository.findAll(pageable).map(this::toDTO);
    }

    @Override
    public ExerciseDTO createExercise(ExerciseDTO dto) {
        if (exerciseRepository.existsByName(dto.getName())) {
            throw new RuntimeException("Exercise with name '" + dto.getName() + "' already exists");
        }

        Exercise exercise = Exercise.builder()
                .name(dto.getName())
                .force(dto.getForce())
                .difficulty(dto.getDifficulty())
                .mechanic(dto.getMechanic())
                .equipment(dto.getEquipment())
                .primaryMuscles(dto.getPrimaryMuscles())
                .secondaryMuscles(dto.getSecondaryMuscles())
                .instructions(dto.getInstructions())
                .images(dto.getImages())
                .category(dto.getCategory())
                .build();

        return toDTO(exerciseRepository.save(exercise));
    }

    @Override
    public ExerciseDTO updateExercise(ExerciseDTO dto) {
        Exercise exercise = exerciseRepository.findById(dto.getUuid()).orElseThrow(() -> new RuntimeException("Exercise not found with uuid"));

        exercise.setName(dto.getName());
        exercise.setForce(dto.getForce());
        exercise.setDifficulty(dto.getDifficulty());
        exercise.setMechanic(dto.getMechanic());
        exercise.setEquipment(dto.getEquipment());
        exercise.setPrimaryMuscles(dto.getPrimaryMuscles());
        exercise.setSecondaryMuscles(dto.getSecondaryMuscles());
        exercise.setInstructions(dto.getInstructions());
        exercise.setImages(dto.getImages());
        exercise.setCategory(dto.getCategory());

        return toDTO(exerciseRepository.save(exercise));
    }

    @Override
    public void deleteExercise(UUID uuid) {
        if (!exerciseRepository.existsById(uuid)) {
            throw new RuntimeException("Exercise not found with uuid: " + uuid);
        }
        exerciseRepository.deleteById(uuid);
    }

    @Override
    public List<Exercise> findTopSimilar(float[] queryVector, int k) {
        String vector = Arrays.toString(queryVector);
        return exerciseRepository.findTopSimilar(vector, k);
    }
}
