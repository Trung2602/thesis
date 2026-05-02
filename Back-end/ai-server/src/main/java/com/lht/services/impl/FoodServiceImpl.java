package com.lht.services.impl;

import com.lht.dto.FoodDTO;
import com.lht.pojo.Food;
import com.lht.repositories.FoodRepository;
import com.lht.services.FoodService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FoodServiceImpl implements FoodService {

    private final FoodRepository foodRepository;

    private FoodDTO toDTO(Food food) {
        FoodDTO dto = new FoodDTO();
        dto.setUuid(food.getUuid());
        dto.setCode(food.getCode());
        dto.setName(food.getName());
        dto.setCategory(food.getCategory());
        dto.setCalories100g(food.getCalories100g());
        return dto;
    }

    @Override
    public FoodDTO getFoodById(UUID uuid) {
        Food food = foodRepository.findById(uuid).orElseThrow(() -> new RuntimeException("Food not found with uuid: " + uuid));
        return toDTO(food);
    }

    @Override
    public Page<FoodDTO> getFoods(int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return foodRepository.findAll(pageable).map(this::toDTO);
    }

    @Override
    public FoodDTO createFood(FoodDTO dto) {
        if (foodRepository.existsByCode(dto.getCode())) {
            throw new RuntimeException("Food with code " + dto.getCode() + " already exists");
        }
        Food food = Food.builder()
                .code(dto.getCode())
                .name(dto.getName())
                .category(dto.getCategory())
                .calories100g(dto.getCalories100g())
                .build();

        Food saved = foodRepository.save(food);
        return toDTO(saved);
    }

    @Override
    public FoodDTO updateFood(FoodDTO dto) {
        Food food = foodRepository.findById(dto.getUuid()).orElseThrow(() -> new RuntimeException("Food not found with uuid"));
        food.setCode(dto.getCode());
        food.setName(dto.getName());
        food.setCategory(dto.getCategory());
        food.setCalories100g(dto.getCalories100g());
        Food updated = foodRepository.save(food);
        return toDTO(updated);
    }

    @Override
    public void deleteFood(UUID uuid) {
        if (!foodRepository.existsById(uuid)) {
            throw new RuntimeException("Food not found with uuid: " + uuid);
        }
        foodRepository.deleteById(uuid);
    }

    public List<Food> findTopSimilar(float[] queryVector, int k) {
        String vector = Arrays.toString(queryVector);
        return foodRepository.findTopSimilar(vector, k);
    }
}
