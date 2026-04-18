package com.lht.controllers;

import com.lht.dto.ChatMessage;
import com.lht.services.ChatHistoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/ai/chat")
public class ChatHistoryController {

    private final ChatHistoryService chatHistoryService;

    @GetMapping("/history")
    public List<ChatMessage> getChatHistory(
            @RequestParam(required = false) LocalDateTime before,
            @RequestParam(defaultValue = "10") int pageSize
    ) {
        return chatHistoryService.getChatHistory(before, pageSize);
    }
}
