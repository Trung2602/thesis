package com.lht.dto;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class NameUUIDDTO {
    private UUID uuid;
    private String name;
}
