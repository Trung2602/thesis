package com.lht.dto;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class AvailableStaffDTO {
    private UUID uuid;
    private String name;
    private UUID facilityUuid;
}
