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

    boolean existsByName(String name);

    @Query(value = """
        SELECT * FROM exercises
        ORDER BY embedding <=> CAST(:vector AS vector)
        LIMIT :k
    """, nativeQuery = true)
    List<Exercise> findTopSimilar(@Param("vector") String vector,
                                  @Param("k") int k);
}