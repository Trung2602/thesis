package com.lht.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
public class AIDayDTO {

    private LocalDate date;

    private List<AIMealDTO> meals;

    private AIWorkoutDTO workout;

}
