package com.lht.services;

import com.lht.dto.PayCustomerDTO;
import com.lht.pojo.PayCustomer;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.lht.pojo.StatusType;
import org.springframework.data.domain.Page;

public interface PayCustomerService {

    List<PayCustomerDTO> getAllPayCustomers();

    PayCustomerDTO getPayCustomerByUuid(UUID uuid);

    PayCustomer getByUuid(UUID uuid);

    PayCustomerDTO addOrUpdatePayCustomer(PayCustomerDTO dto);

    PayCustomer createPayCustomer(PayCustomer entity);

    boolean deletePayCustomer(UUID uuid);
    void deleteByCustomerUuid(UUID customerUuid);
    void deleteByPlanUuid(UUID planUuid);
    List<PayCustomerDTO> getPayCustomers(Map<String, String> params);

    Page<PayCustomerDTO> getAllSort(String sortField, String sortDir, int page, int size);
    
    List<PayCustomerDTO> getPayCustomerByCustomerUuid(UUID uuid);
    
    void updatePaymentStatus(PayCustomer pay, String txnRef, StatusType status, String bankCode);
}
