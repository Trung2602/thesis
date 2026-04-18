package com.lht.services;

import com.lht.dto.ChatMessage;
import com.lht.pojo.ChatHistory;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface ChatHistoryService {
    ChatHistory saveChat(UUID userUuid, String userMessage, String aiReply);
    List<ChatMessage> getChatHistory(LocalDateTime before, int pageSize);
}
