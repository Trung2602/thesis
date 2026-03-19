package com.lht.repositories;

import com.lht.pojo.WorkoutItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface WorkoutItemRepository extends JpaRepository<WorkoutItem, UUID> {
}
