package com.lht.pojo;

import org.hibernate.annotations.Generated;
import org.hibernate.annotations.GenerationTime;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "staff_day_off")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StaffDayOff {

    @Id
    @Column(columnDefinition = "uuid", updatable = false, nullable = false)
    @Generated(GenerationTime.INSERT)
    private UUID uuid;

    @Column(name = "date_off", nullable = false)
    private LocalDate dateOff;

    @Column(name = "staff_uuid", nullable = false)
    private UUID staffUuid;
}