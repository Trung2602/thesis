package com.lht.pojo;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "user_profiles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserProfile {

    @Id
    private UUID uuid;

    @Column(name = "user_uuid")
    private UUID userUuid;

    private Integer age;

    @Column(name = "height_cm")
    private Float heightCm;

    @Column(name = "weight_kg")
    private Float weightKg;

    private Float bmi;

    @Enumerated(EnumType.STRING)
    private FitnessGoalEnum goal;

    @Enumerated(EnumType.STRING)
    @Column(name = "activity_level")
    private ActivityLevelEnum activityLevel;

    @Column(name = "free_time_minutes")
    private Integer freeTimeMinutes;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
}
