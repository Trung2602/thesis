package com.lht.pojo;

import com.pgvector.PGvector;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "exercises")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Exercise {

    @Id
    private UUID uuid;

    private String name;

    private String force;

    private String difficulty;

    private String mechanic;

    private String equipment;

    @Column(name = "primary_muscles")
    private List<String> primaryMuscles;

    @Column(name = "secondary_muscles")
    private List<String> secondaryMuscles;

    @Column(columnDefinition = "text[]")
    private List<String> instructions;

    @Column(columnDefinition = "text[]")
    private List<String> images;

    private String category;

    @Column(name = "embedding", columnDefinition = "vector(768)")
    private PGvector embedding;
}
