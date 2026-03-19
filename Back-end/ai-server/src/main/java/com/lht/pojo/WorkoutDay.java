package com.lht.pojo;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "workout_days")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WorkoutDay {

    @Id
    private UUID uuid;

    @Column(name = "user_uuid")
    private UUID userUuid;

    private LocalDate date;

    @Enumerated(EnumType.STRING)
    @Column(name = "focus_muscle")
    private MuscleGroupEnum focusMuscle;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
}