package com.lht.repositories;

import com.lht.pojo.WorkoutDay;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface WorkoutDayRepository extends JpaRepository<WorkoutDay, UUID> {
}