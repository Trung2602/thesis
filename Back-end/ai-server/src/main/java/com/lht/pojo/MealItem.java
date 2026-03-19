package com.lht.pojo;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "meal_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MealItem {

    @Id
    private UUID uuid;

    @ManyToOne
    @JoinColumn(name = "meal_day_uuid")
    private MealDay mealDay;

    @Enumerated(EnumType.STRING)
    @Column(name = "meal_type")
    private MealTypeEnum mealType;

    @ManyToOne
    @JoinColumn(name = "food_uuid")
    private Food food;

    private Float grams;
}
