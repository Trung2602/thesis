package com.lht.controllers.api;

import com.lht.dto.ExerciseDTO;
import com.lht.services.ExerciseService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/ai/exercises")
@RequiredArgsConstructor
public class ApiExerciseController {

    private final ExerciseService exerciseService;

    @GetMapping
    public ResponseEntity<Page<ExerciseDTO>> getExercises(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(exerciseService.getExercises(page, size));
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<ExerciseDTO> getExerciseById(@PathVariable UUID uuid) {
        return ResponseEntity.ok(exerciseService.getExerciseById(uuid));
    }

    @PostMapping
    public ResponseEntity<ExerciseDTO> createExercise(@RequestBody ExerciseDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(exerciseService.createExercise(dto));
    }

    @PatchMapping
    public ResponseEntity<ExerciseDTO> updateExercise(@RequestBody ExerciseDTO dto) {
        return ResponseEntity.ok(exerciseService.updateExercise(dto));
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> deleteExercise(@PathVariable UUID uuid) {
        exerciseService.deleteExercise(uuid);
        return ResponseEntity.noContent().build();
    }
}
