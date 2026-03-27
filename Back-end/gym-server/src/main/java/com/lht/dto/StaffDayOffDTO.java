package com.lht.dto;

import lombok.*;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StaffDayOffDTO {

    private UUID uuid;
    private LocalDate date;
}
