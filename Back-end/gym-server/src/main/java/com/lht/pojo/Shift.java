package com.lht.pojo;

import org.hibernate.annotations.Generated;
import org.hibernate.annotations.GenerationTime;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.UUID;

@Entity
@Table(name = "shift")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Shift {

    @Id
    @Column(columnDefinition = "uuid", updatable = false, nullable = false)
    @Generated(GenerationTime.INSERT)
    private UUID uuid;

    @Column(nullable = false, length = 50)
    private String name;

    @Column(nullable = false)
    private LocalTime checkin;

    @Column(nullable = false)
    private LocalTime checkout;

    @Column(precision = 4, scale = 2)
    private BigDecimal duration;
}
