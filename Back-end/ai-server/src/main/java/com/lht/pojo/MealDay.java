package com.lht.pojo;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "meal_days")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MealDay {

    @Id
    private UUID uuid;

    @Column(name = "user_uuid")
    private UUID userUuid;

    private LocalDate date;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
}
