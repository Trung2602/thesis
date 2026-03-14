package com.lht.pojo;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Entity
@Table(name = "customer_schedule")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerSchedule {

    @Id
    @Column(columnDefinition = "uuid", updatable = false, nullable = false)
    private UUID uuid;

    @Column(nullable = false)
    private LocalDate date;

    @Column(nullable = false)
    private LocalTime checkin;

    @Column(nullable = false)
    private LocalTime checkout;

    @Column(name = "facility_uuid", nullable = false)
    private UUID facilityUuid;

    @Column(name = "staff_uuid", nullable = false)
    private UUID staffUuid;

    @Column(name = "customer_uuid", nullable = false)
    private UUID customerUuid;
}
