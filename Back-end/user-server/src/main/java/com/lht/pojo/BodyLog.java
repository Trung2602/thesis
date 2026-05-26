package com.lht.pojo;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Generated;
import org.hibernate.annotations.GenerationTime;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "body_log")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BodyLog {

    @Id
    @Generated(GenerationTime.INSERT)
    @Column(columnDefinition = "uuid")
    private UUID uuid;

    @Column(name = "customer_uuid", nullable = false)
    private UUID customerUuid;

    @Column(nullable = false, precision = 5, scale = 2)
    private BigDecimal weight;

    @Column(nullable = false, precision = 4, scale = 1)
    private BigDecimal height;

    @Column(name = "body_fat_percent", precision = 4, scale = 1)
    private BigDecimal bodyFatPercent;

    @Column(name = "muscle_mass", precision = 5, scale = 2)
    private BigDecimal muscleMass;

    @Column(name = "staff_uuid", nullable = false)
    private UUID staffUuid;

    private String note;

    @Column(name = "logged_at")
    private LocalDateTime loggedAt;

    @PrePersist
    public void prePersist() {
        if (loggedAt == null) loggedAt = LocalDateTime.now();
    }
}
