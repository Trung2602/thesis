package com.lht.dto;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CustomerDTO {
    private UUID uuid;
    private LocalDate birthday;
    private BigDecimal height;
    private BigDecimal weight;
}
