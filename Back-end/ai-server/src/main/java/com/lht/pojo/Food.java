package com.lht.pojo;

import com.pgvector.PGvector;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Type;

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

    private int code;

    private String name;

    private String category;

    @Column(name = "calories_100g")
    private Float calories100g;

    @Column(name = "embedding", columnDefinition = "vector(768)")
    @Type(PGvectorType.class)
    private PGvector embedding;
}
