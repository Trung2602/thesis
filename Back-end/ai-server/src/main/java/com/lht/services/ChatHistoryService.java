package com.lht.services;

import com.lht.pojo.ChatHistory;

import java.util.UUID;

public interface ChatHistoryService {
    ChatHistory saveChat(UUID userUuid, String userMessage, String aiReply);
}
