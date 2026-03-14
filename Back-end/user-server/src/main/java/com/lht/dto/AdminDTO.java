package com.lht.dto;

import com.lht.pojo.Account;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
@SuperBuilder
public class AdminDTO extends AccountDTO {

    private String permissions;

    public AdminDTO(Account acc) {
        super(acc);
    }
}