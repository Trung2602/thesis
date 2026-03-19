package com.lht.repositories;

import com.lht.pojo.MealDay;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface MealDayRepository extends JpaRepository<MealDay, UUID> {
}
