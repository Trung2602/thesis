package com.lht.pojo;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "customer")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
@PrimaryKeyJoinColumn(name = "account_uuid")
public class Customer extends Account {

    @Column(name = "weight", nullable = false, precision = 5, scale = 2)
    private BigDecimal weight;

    @Column(name = "height", nullable = false, precision = 4, scale = 1)
    private BigDecimal height;

    @Column(name = "expiry_date", nullable = false)
    private LocalDate expiryDate;
}