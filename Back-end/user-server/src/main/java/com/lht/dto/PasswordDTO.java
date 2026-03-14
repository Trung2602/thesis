package com.lht.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PasswordDTO {
    private String password;
    private String newPassword;
}
