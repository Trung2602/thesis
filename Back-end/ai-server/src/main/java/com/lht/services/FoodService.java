package com.lht.services;

import com.lht.pojo.Food;

import java.util.List;

public interface FoodService {
    List<Food> findTopSimilar(float[] queryVector, int k);
}
