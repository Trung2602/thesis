package com.lht.controllers;

import com.lht.component.SecurityUtils;
import com.lht.services.RagService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
public class RagController {

    private final RagService ragService;

    @PostMapping("/fitness")
    public String askAI(@RequestBody Map<String, String> body) {
        String question = body.get("question");
        if (question == null || question.isEmpty()) {
            return "Question is required!";
        }
        UUID uuid = SecurityUtils.getCurrentUserUuid();
        return ragService.askFitnessAI(uuid, question);
    }
}