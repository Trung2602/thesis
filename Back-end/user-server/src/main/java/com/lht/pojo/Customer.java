package com.lht.pojo;

import jakarta.persistence.*;
import lombok.*;

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

    @Column(name = "expiry_date", nullable = false)
    private LocalDate expiryDate;
}