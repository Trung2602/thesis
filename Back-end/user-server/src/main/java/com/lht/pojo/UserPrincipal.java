package com.lht.pojo;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class UserPrincipal {
    private UUID uuid;
    private String mail;
}

