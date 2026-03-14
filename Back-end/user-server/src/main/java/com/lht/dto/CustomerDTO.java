package com.lht.dto;

import com.lht.pojo.Account;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
@SuperBuilder
public class CustomerDTO extends AccountDTO {

    private LocalDate expiryDate;

    public CustomerDTO(Account acc) {
        super(acc);
    }
}