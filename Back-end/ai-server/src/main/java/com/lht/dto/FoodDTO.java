package com.lht.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class FoodDTO {

    private UUID uuid;
    private int code;
    private String name;
    private String category;
    private Float calories100g;
}
