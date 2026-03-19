package com.lht.pojo;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "workout_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WorkoutItem {

    @Id
    private UUID uuid;

    @ManyToOne
    @JoinColumn(name = "workout_day_uuid")
    private WorkoutDay workoutDay;

    @ManyToOne
    @JoinColumn(name = "exercise_uuid")
    private Exercise exercise;

    @Column(name = "number_sets")
    private Integer numberSets;

    @Column(name = "number_reps")
    private Integer numberReps;

    @Column(name = "duration_minutes")
    private Integer durationMinutes;
}