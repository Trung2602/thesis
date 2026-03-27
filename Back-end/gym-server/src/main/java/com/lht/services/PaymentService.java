package com.lht.services;

import com.lht.pojo.StatusType;

import java.util.Map;
import java.util.UUID;

public interface PaymentService {
    String createPaymentUrl(UUID planUuid, String mail, String ip) throws Exception;
    StatusType handleReturn(Map<String, String> params) throws Exception;
}
