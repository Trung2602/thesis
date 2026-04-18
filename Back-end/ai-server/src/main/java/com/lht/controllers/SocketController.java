package com.lht.controllers;

import com.lht.dto.ChatMessage;
import com.lht.pojo.UserPrincipal;
import com.lht.services.ChatHistoryService;
import com.lht.services.RagService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;

@RestController
@RequiredArgsConstructor
public class SocketController {

    private final RagService ragService;
    private final ChatHistoryService chatHistoryService;
    private final SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/api/v1/ai/ai.ask")
    public void askAI(ChatMessage message, Principal principal) {
        if (!(principal instanceof UsernamePasswordAuthenticationToken authToken)) {
            System.out.println("Principal is not set!");
            return;
        }
        UserPrincipal userPrincipal = (UserPrincipal) authToken.getPrincipal();
        UUID userUuid = userPrincipal.getUuid();

        CompletableFuture.supplyAsync(() -> ragService.askFitnessAI(userUuid, message.getQuestion()))
                .thenAccept(answer -> {
                    messagingTemplate.convertAndSend(
                            "/topic/ai",
                            new ChatMessage(message.getQuestion(), answer, null)
                    );
                    chatHistoryService.saveChat(userUuid, message.getQuestion(), answer);
                });
    }
}