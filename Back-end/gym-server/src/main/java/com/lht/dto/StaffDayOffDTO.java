package com.lht.dto;

import com.lht.pojo.StaffDayOff;
import lombok.*;

import java.time.LocalDate;
import java.util.Date;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StaffDayOffDTO {

    private UUID uuid;
    private LocalDate date;

    private UUID staffUuid;
    private String staffName;
}
