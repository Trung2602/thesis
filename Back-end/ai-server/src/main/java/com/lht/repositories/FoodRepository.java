package com.lht.repositories;

import com.lht.pojo.Food;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface FoodRepository extends JpaRepository<Food, UUID> {

    boolean existsByCode(int code);

    @Query(value = """
    SELECT * FROM foods
    ORDER BY embedding <=> CAST(:vector AS vector)
    LIMIT :k
""", nativeQuery = true)
    List<Food> findTopSimilar(@Param("vector") String vector,
                              @Param("k") int k);
}