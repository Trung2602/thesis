package com.lht.pojo;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "staff")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
@PrimaryKeyJoinColumn(name = "account_uuid")
public class Staff extends Account {

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private StaffType type;

    @Column(name = "base_salary", nullable = false, precision = 11, scale = 2)
    private BigDecimal baseSalary;

    @Column(name = "facility_uuid", nullable = false)
    private UUID facilityUuid;
}