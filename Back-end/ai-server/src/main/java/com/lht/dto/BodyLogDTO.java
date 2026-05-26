package com.lht.dto;

import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BodyLogDTO {
    private UUID uuid;
    private UUID customerUuid;
    private BigDecimal weight;
    private BigDecimal height;
    private BigDecimal bodyFatPercent;
    private BigDecimal muscleMass;
    private UUID staffUuid;
    private String note;
}
