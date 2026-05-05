package com.lht.repositories;

import com.lht.pojo.ChatHistory;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface ChatHistoryRepository extends JpaRepository<ChatHistory, UUID> {
    List<ChatHistory> findByUserUuidOrderByCreatedAtDesc(UUID userUuid, Pageable pageable);
    List<ChatHistory> findByUserUuidAndCreatedAtBeforeOrderByCreatedAtDesc(
            UUID userUuid, LocalDateTime before, Pageable pageable
    );

    @Query("""
        SELECT c FROM ChatHistory c
        WHERE c.userUuid = :userUuid
        ORDER BY c.createdAt DESC
    """)
    List<ChatHistory> findTopByUserUuidOrderByCreatedAtDesc(
            @Param("userUuid") UUID userUuid,
            Pageable pageable
    );
}