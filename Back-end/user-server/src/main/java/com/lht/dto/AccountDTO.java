package com.lht.dto;

import com.lht.pojo.Account;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class AccountDTO {

    private UUID uuid;
    private String mail;
    private String name;

    private String role;

    private String avatar;
    private LocalDate birthday;
    private String gender;
    private Boolean isActive;

    public AccountDTO(Account acc) {
        this.uuid = acc.getUuid();
        this.mail = acc.getMail();
        this.name = acc.getName();
        this.role = acc.getRole().name();
        this.avatar = acc.getAvatar();
        this.birthday = acc.getBirthday();
        this.gender = acc.getGender().name();
        this.isActive = acc.getIsActive();
    }
}
