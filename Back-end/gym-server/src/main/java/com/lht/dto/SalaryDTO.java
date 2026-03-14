package com.lht.dto;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Date;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SalaryDTO {

    private UUID uuid;
    private LocalDate date;
    private BigDecimal duration;
    private Integer dayOff;
    private BigDecimal price;

    private UUID staffUuid;
    private String staffName;
}
