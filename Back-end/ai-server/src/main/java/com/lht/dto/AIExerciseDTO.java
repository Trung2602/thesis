package com.lht.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class AIExerciseDTO {

    private UUID exerciseUuid;
    private int numberSets;
    private int numberReps;
    private Integer durationMinutes;
}
