package com.lht.dto;

import lombok.*;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PayCustomerDTO {

    private UUID uuid;
    private LocalDate date;

    private UUID customerUuid;
    private String customerName;

    private UUID planUuid;
    private String planName;
    private Integer price; // plan.price

    private String txnRef;   // thêm mã giao dịch VNPAY
    private String status;   // PENDING / SUCCESS / FAILED
    private String bankCode; // optional, ngân hàng
}
