package com.lht.controllers;

import com.lht.component.SecurityUtils;
import com.lht.pojo.ChatHistory;
import com.lht.repositories.ChatHistoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/chat")
public class ChatHistoryController {

    private final ChatHistoryRepository chatHistoryRepository;

    @GetMapping("/history")
    public List<ChatHistory> getChatHistory(
            @RequestParam(required = false) LocalDateTime before,
            @RequestParam(defaultValue = "5") int pageSize
    ) {
        UUID userUuid = SecurityUtils.getCurrentUserUuid();
        Pageable pageable = PageRequest.of(0, pageSize, Sort.by("createdAt").descending());
        if (before != null) {
            return chatHistoryRepository.findByUserUuidAndCreatedAtBeforeOrderByCreatedAtDesc(userUuid, before, pageable);
        } else {
            return chatHistoryRepository.findByUserUuidOrderByCreatedAtDesc(userUuid, pageable);
        }
    }
}
