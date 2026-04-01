package com.lht.pojo;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Generated;
import org.hibernate.annotations.GenerationTime;

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
    @Generated(GenerationTime.INSERT)
    private UUID uuid;

    @Column(name = "user_uuid")
    private UUID userUuid;

    @Column(columnDefinition = "TEXT")
    private String message;

    @Column(name = "ai_reply", columnDefinition = "TEXT")
    private String aiReply;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
}
