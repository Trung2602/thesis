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
        // Lấy câu hỏi từ body JSON
        String question = body.get("question");
        if (question == null || question.isEmpty()) {
            return "Question is required!";
        }

        // Lấy user UUID hiện tại
        UUID uuid = SecurityUtils.getCurrentUserUuid();

        // Gọi RagService trả kết quả
        return ragService.askFitnessAI(uuid, question);
    }
}