package com.lht.controllers;

import com.lht.services.EmbeddingInitializerService;
import com.lht.services.EmbeddingService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/embedding")
@RequiredArgsConstructor
public class EmbeddingController {

    private final EmbeddingInitializerService embeddingInitializerService;

    @PostMapping("/food")
    public String initFood() {
        embeddingInitializerService.initFoodEmbedding();
        return "done";
    }

    @PostMapping("/exercise")
    public String initExercise() {
        embeddingInitializerService.initExerciseEmbedding();
        return "done";
    }
}
