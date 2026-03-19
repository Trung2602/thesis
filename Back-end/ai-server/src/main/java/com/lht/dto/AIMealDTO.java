package com.lht.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class AIMealDTO {

    private String type;

    private List<AIMealItemDTO> items;

}
