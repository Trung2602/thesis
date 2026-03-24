package com.lht.dto;

import com.lht.pojo.Account;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
@SuperBuilder
public class CustomerDTO extends AccountDTO {

    private BigDecimal weight;
    private BigDecimal height;
    private LocalDate expiryDate;
    public CustomerDTO(Account acc) {
        super(acc);
    }
}