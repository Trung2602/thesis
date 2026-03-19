package com.lht.services.impl;

import com.lht.pojo.Food;
import com.lht.repositories.FoodRepository;
import com.lht.services.EmbeddingService;
import com.lht.services.FoodService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FoodServiceImpl implements FoodService {

    private final FoodRepository foodRepository;
    private final EmbeddingService embeddingService;

    @Override
    public List<Food> findFoodsForDiet(String query) {

        String embedding = embeddingService.createEmbedding(query);

        return foodRepository.searchByEmbedding(embedding, 20);
    }
}
