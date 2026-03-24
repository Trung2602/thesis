package com.lht.services;

import com.lht.pojo.Exercise;

import java.util.List;

public interface ExerciseService {
    List<Exercise> findExercisesForWorkout(String query);
}