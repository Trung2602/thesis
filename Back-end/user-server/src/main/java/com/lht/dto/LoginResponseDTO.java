package com.lht.dto;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginResponseDTO {

    private UUID uuid;
    private String mail;
    private String role;
    private String token;
    private String firebaseToken;
}