package com.lht.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CustomerBMIDTO {
    private UUID uuid;
    private String gender;
    private LocalDate birthday;
    private BigDecimal height;
    private BigDecimal weight;
}
