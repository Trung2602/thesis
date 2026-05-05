package com.lht.services.impl;

import com.lht.component.SecurityUtils;
import com.lht.dto.ChatMessage;
import com.lht.pojo.ChatHistory;
import com.lht.repositories.ChatHistoryRepository;
import com.lht.services.ChatHistoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ChatHistoryServiceImpl implements ChatHistoryService{

    private final ChatHistoryRepository chatHistoryRepository;

    @Override
    public ChatHistory saveChat(UUID uuid, String userMessage, String aiReply) {
        ChatHistory chat = ChatHistory.builder()
                .userUuid(uuid)
                .message(userMessage)
                .aiReply(aiReply)
                .createdAt(LocalDateTime.now())
                .build();
        return chatHistoryRepository.save(chat);
    }

    public List<ChatMessage> getChatHistory(LocalDateTime before, int pageSize) {
        UUID userUuid = SecurityUtils.getCurrentUserUuid();
        Pageable pageable = PageRequest.of(0, pageSize, Sort.by("createdAt").descending());
        List<ChatHistory> histories;
        if (before != null) {histories = chatHistoryRepository.
                findByUserUuidAndCreatedAtBeforeOrderByCreatedAtDesc(userUuid, before, pageable);
        } else {
            histories = chatHistoryRepository.findByUserUuidOrderByCreatedAtDesc(userUuid, pageable);
        }
        return histories.stream()
            .map(h -> new ChatMessage(
                    h.getMessage(),
                    h.getAiReply(),
                    h.getCreatedAt()
            ))
            .toList();
    }

    @Override
    public List<ChatHistory> getRecentChats(UUID uuid, int limit) {
        return chatHistoryRepository.findTopByUserUuidOrderByCreatedAtDesc(uuid, PageRequest.of(0, limit));
    }
}
