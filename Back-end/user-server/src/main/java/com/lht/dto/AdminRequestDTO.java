package com.lht.dto;

import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AdminRequestDTO {

    private String mail;
    private String password;
    private String name;
    private LocalDate birthday;
    private String gender;
    private String permissions;
}
