package com.lht.controllers;

import com.lht.services.RagService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
public class RagController {

    private final RagService ragService;

    @GetMapping("/fitness")
    public String askAI(
            @RequestParam double weight,
            @RequestParam double height,
            @RequestParam String question
    ) {

        return ragService.askFitnessAI(weight, height, question);
    }
}