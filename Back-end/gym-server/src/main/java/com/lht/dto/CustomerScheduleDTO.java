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
public class CustomerScheduleDTO {

    private UUID uuid;
    private LocalDate date;
    private LocalTime checkin;
    private LocalTime checkout;

    private UUID customerUuid;
    private UUID staffUuid;
    private UUID facilityUuid;

    private String customerName;
    private String facilityName;
    private String staffName;
}
