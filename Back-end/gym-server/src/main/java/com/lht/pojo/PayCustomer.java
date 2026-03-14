package com.lht.pojo;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "pay_customer")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PayCustomer {

    @Id
    @Column(columnDefinition = "uuid", updatable = false, nullable = false)
    private UUID uuid;

    @Column(nullable = false)
    private LocalDate date;

    @Column(name = "plan_uuid", nullable = false)
    private UUID planUuid;

    @Column(name = "customer_uuid", nullable = false)
    private UUID customerUuid;

    @Column(name = "txn_ref", length = 50)
    private String txnRef;

    @Column(name = "bank_code", length = 20)
    private String bankCode;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatusType status;
}