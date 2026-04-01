package com.lht.services.impl;

import com.lht.pojo.Food;
import com.lht.repositories.FoodRepository;
import com.lht.services.FoodService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;

@Service
@RequiredArgsConstructor
public class FoodServiceImpl implements FoodService {

    private final FoodRepository foodRepository;

    public List<Food> findTopSimilar(float[] queryVector, int k) {
        String vector = Arrays.toString(queryVector);
        return foodRepository.findTopSimilar(vector, k);
    }
}
