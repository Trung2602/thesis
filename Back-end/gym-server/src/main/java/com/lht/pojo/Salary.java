package com.lht.pojo;

import org.hibernate.annotations.Generated;
import org.hibernate.annotations.GenerationTime;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "salary")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Salary {

    @Id
    @Column(columnDefinition = "uuid", updatable = false, nullable = false)
    @Generated(GenerationTime.INSERT)
    private UUID uuid;

    @Column(nullable = false)
    private LocalDate date;

    @Column(precision = 5, scale = 2)
    private BigDecimal duration;

    @Column(name = "day_off")
    private Integer dayOff;

    @Column(precision = 12, scale = 2)
    private BigDecimal price;

    @Column(name = "staff_uuid", nullable = false)
    private UUID staffUuid;
}
