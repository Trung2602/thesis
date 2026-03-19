package com.lht.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class AIMealItemDTO {

    private UUID foodUuid;
    private double grams;
}