package com.lht.pojo;

import org.hibernate.annotations.Generated;
import org.hibernate.annotations.GenerationTime;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "staff_schedule")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StaffSchedule {

    @Id
    @Column(columnDefinition = "uuid", updatable = false, nullable = false)
    @Generated(GenerationTime.INSERT)
    private UUID uuid;

    @Column(nullable = false)
    private LocalDate date;

    @Column(name = "shift_uuid", nullable = false)
    private UUID shiftUuid;

    @Column(name = "staff_uuid", nullable = false)
    private UUID staffUuid;
}
