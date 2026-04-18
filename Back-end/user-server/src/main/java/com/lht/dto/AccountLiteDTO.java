package com.lht.dto;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class AccountLiteDTO {
    private UUID uuid;
    private String name;
    private String mail;
    private String role;
}
