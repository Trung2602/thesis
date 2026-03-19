package com.lht.pojo;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "chat_history")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatHistory {

    @Id
    private UUID uuid;

    @Column(name = "user_uuid")
    private UUID userUuid;

    private String message;

    @Column(name = "ai_reply")
    private String aiReply;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
}
