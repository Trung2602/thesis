package com.lht.dto;

import lombok.*;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AdminRequestDTO {

    private UUID uuid;
    private String mail;
    private String password;
    private String name;
    private LocalDate birthday;
    private String gender;
    private String permissions;
    private Boolean isActive;
}
