package com.lht.dto;

import com.lht.pojo.Account;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
@SuperBuilder
public class StaffDTO extends AccountDTO {

    private String type;
    private BigDecimal baseSalary;

    private String facilityName;

    public StaffDTO(Account acc) {
        super(acc);
    }
}