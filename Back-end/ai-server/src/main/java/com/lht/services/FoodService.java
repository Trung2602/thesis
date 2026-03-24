package com.lht.services;

import com.lht.pojo.Food;

import java.util.List;

public interface FoodService {
    List<Food> findFoodsForDiet(String query);
}
