package com.lht.services.impl;

import com.lht.pojo.ChatHistory;
import com.lht.repositories.ChatHistoryRepository;
import com.lht.services.ChatHistoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ChatHistoryServiceImpl implements ChatHistoryService{

    private final ChatHistoryRepository chatHistoryRepository;

    @Override
    public ChatHistory saveChat(UUID userUuid, String userMessage, String aiReply) {
        ChatHistory chat = ChatHistory.builder()
                .userUuid(userUuid)
                .message(userMessage)
                .aiReply(aiReply)
                .createdAt(LocalDateTime.now())
                .build();
        return chatHistoryRepository.save(chat);
    }
}
