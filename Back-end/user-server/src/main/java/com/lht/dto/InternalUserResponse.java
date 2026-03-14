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
public class InternalUserResponse {

    private UUID uuid;
    private String role;
    private BigDecimal baseSalary;
    private String staffType;
    private LocalDate expiryDate;
}
