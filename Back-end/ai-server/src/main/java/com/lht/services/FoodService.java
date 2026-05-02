package com.lht.services;

import com.lht.dto.FoodDTO;
import com.lht.pojo.Food;
import org.springframework.data.domain.Page;

import java.util.List;
import java.util.UUID;

public interface FoodService {
    Page<FoodDTO> getFoods(int page, int size);
    FoodDTO getFoodById(UUID uuid);
    FoodDTO createFood(FoodDTO dto);
    FoodDTO updateFood(FoodDTO dto);
    void deleteFood(UUID uuid);
    List<Food> findTopSimilar(float[] queryVector, int k);
}
