package com.lht.pojo;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Generated;
import org.hibernate.annotations.GenerationTime;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "goal")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Goal {

    @Id
    @Generated(GenerationTime.INSERT)
    @Column(columnDefinition = "uuid")
    private UUID uuid;

    @Column(name = "customer_uuid", nullable = false)
    private UUID customerUuid;

    @Column(name = "goal_type", nullable = false, length = 20)
    private String goalType;

    @Column(name = "target_weight", precision = 5, scale = 2)
    private BigDecimal targetWeight;

    @Column(name = "target_body_fat", precision = 4, scale = 1)
    private BigDecimal targetBodyFat;

    private LocalDate deadline;

    @Column(name = "is_achieved")
    private Boolean isAchieved;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        if (isAchieved == null) isAchieved = false;
        if (createdAt == null) createdAt = LocalDateTime.now();
    }
}
