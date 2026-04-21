package com.lht.dto;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CustomerRequestDTO {

    private UUID uuid;
    private String mail;
    private String password;
    private String name;
    private LocalDate birthday;
    private String gender;
    private BigDecimal weight;
    private BigDecimal height;
    private LocalDate expiryDate;
    private Boolean isActive;
}
