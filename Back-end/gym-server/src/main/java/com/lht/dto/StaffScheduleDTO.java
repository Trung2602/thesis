package com.lht.dto;

import lombok.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StaffScheduleDTO {

    private UUID uuid;
    private LocalDate date;

    private UUID staffUuid;
    private String staffName;

    private UUID shiftUuid;
    private String shiftName;
}
