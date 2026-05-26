package com.lht.dto;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GoalDTO {
    private UUID uuid;
    private UUID customerUuid;
    private String goalType;
    private BigDecimal targetWeight;
    private BigDecimal targetBodyFat;
    private LocalDate deadline;
    private Boolean isAchieved;
}
