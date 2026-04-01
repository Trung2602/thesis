package com.lht.dto;

import lombok.*;

@Data
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class ChatMessage {
    private String question;
    private String answer;
}
