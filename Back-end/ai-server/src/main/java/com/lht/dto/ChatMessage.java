package com.lht.dto;

import lombok.*;

import java.time.LocalDateTime;

@Data
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class ChatMessage {
    private String question;
    private String answer;
    private LocalDateTime createdAt;
}
