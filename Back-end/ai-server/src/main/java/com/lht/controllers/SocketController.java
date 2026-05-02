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
import org.springframework.web.client.HttpServerErrorException;

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
        CompletableFuture.supplyAsync(() -> {
            return ragService.askFitnessAI(userUuid, message.getQuestion());
        }).whenComplete((answer, ex) -> {
            if (ex != null) {
                Throwable cause = ex.getCause() != null ? ex.getCause() : ex;

                String errorMsg;
                if (cause instanceof HttpServerErrorException e && e.getStatusCode().value() == 503) {
                    System.out.println("Mã lỗi 503");
                    errorMsg = "AI đang bận, vui lòng thử lại sau ít phút ⏳";
                } else {
                    errorMsg = "Đã xảy ra lỗi: " + cause.getMessage();
                }

                messagingTemplate.convertAndSend("/topic/ai",
                        new ChatMessage(message.getQuestion(), errorMsg, null)
                );
                return;
            }

            messagingTemplate.convertAndSend("/topic/ai",
                    new ChatMessage(message.getQuestion(), answer, null)
            );
            chatHistoryService.saveChat(userUuid, message.getQuestion(), answer);
        });
    }
}