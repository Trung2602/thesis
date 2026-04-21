package com.lht.dto;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class StaffRequestDTO {

    private UUID uuid;
    private String mail;
    private String password;
    private String name;
    private LocalDate birthday;
    private String gender;
    private BigDecimal baseSalary;
    private String type;
    private UUID facilityUuid;
    private Boolean isActive;
}
