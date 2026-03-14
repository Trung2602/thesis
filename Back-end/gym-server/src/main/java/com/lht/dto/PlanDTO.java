package com.lht.dto;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanDTO {

    private UUID uuid;
    private String name;
    private Integer price;
    private Integer durationDays;
    private String description;
}
