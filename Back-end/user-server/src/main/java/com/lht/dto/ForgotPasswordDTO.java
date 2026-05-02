package com.lht.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ForgotPasswordDTO {
    private String mail;
    private int otp;
    private boolean verified = false;
    private long createdAt;

    public ForgotPasswordDTO(String mail, int otp) {
        this.mail = mail;
        this.otp = otp;
        this.createdAt = System.currentTimeMillis();
    }

    public boolean isExpired() {
        return System.currentTimeMillis() - createdAt > 5 * 60 * 1000;
    }
}
