package com.lht.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class AIWorkoutDTO {

    private String focusMuscle;
    private List<AIExerciseDTO> exercises;

}
