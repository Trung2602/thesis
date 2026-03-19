package com.lht.repositories;

import com.lht.pojo.Exercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ExerciseRepository extends JpaRepository<Exercise, UUID> {

    @Query(value = """
        SELECT *
        FROM exercises
        ORDER BY embedding <-> CAST(:embedding AS vector)
        LIMIT :limit
        """, nativeQuery = true)
    List<Exercise> searchByEmbedding(
            @Param("embedding") String embedding,
            @Param("limit") int limit
    );
}