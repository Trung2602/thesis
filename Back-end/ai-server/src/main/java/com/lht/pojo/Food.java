package com.lht.pojo;

import com.pgvector.PGvector;
import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "foods")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Food {

    @Id
    private UUID uuid;

    private String name;

    private String category;

    @Column(name = "calories_100g")
    private Float calories100g;

    @Column(name = "protein_100g")
    private Float protein100g;

    @Column(name = "carbs_100g")
    private Float carbs100g;

    @Column(name = "fat_100g")
    private Float fat100g;

    @Column(name = "embedding", columnDefinition = "vector(768)")
    private PGvector embedding;
}
