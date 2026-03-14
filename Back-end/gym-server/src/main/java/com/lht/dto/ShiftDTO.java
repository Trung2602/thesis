package com.lht.dto;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ShiftDTO {

    private UUID uuid;
    private String name;
    private LocalTime checkin;
    private LocalTime checkout;
    private BigDecimal duration;
}
