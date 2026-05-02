package com.lht.controllers.api;

import com.lht.dto.FoodDTO;
import com.lht.services.FoodService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/ai/foods")
@RequiredArgsConstructor
public class ApiFoodController {

    private final FoodService foodService;

    @GetMapping
    public ResponseEntity<Page<FoodDTO>> getFoods(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(foodService.getFoods(page, size));
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<FoodDTO> getFoodById(@PathVariable UUID uuid) {
        return ResponseEntity.ok(foodService.getFoodById(uuid));
    }

    @PostMapping
    public ResponseEntity<FoodDTO> createFood(@RequestBody FoodDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(foodService.createFood(dto));
    }

    @PatchMapping
    public ResponseEntity<FoodDTO> updateFood(@RequestBody FoodDTO dto) {
        return ResponseEntity.ok(foodService.updateFood(dto));
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> deleteFood(@PathVariable UUID uuid) {
        foodService.deleteFood(uuid);
        return ResponseEntity.noContent().build();
    }
}
