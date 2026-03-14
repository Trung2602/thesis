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

    private String mail;
    private String password;
    private String name;
    private LocalDate birthday;
    private String gender;

    private LocalDate expiryDate;
}
