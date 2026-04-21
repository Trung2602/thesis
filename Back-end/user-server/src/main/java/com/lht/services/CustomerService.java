package com.lht.services;

import com.lht.dto.CustomerBMIDTO;
import com.lht.dto.CustomerDTO;
import com.lht.dto.CustomerRequestDTO;
import com.lht.pojo.Customer;
import org.springframework.web.multipart.MultipartFile;

import java.util.*;

public interface CustomerService {

    CustomerDTO getCustomerByUuid(UUID uuid);
    Customer getByUuid(UUID uuid);
    List<CustomerDTO> getCustomers(Map<String, String> params);
    CustomerDTO createCustomerAndAvatar(CustomerRequestDTO dto, MultipartFile file);
    CustomerDTO createCustomer(CustomerRequestDTO dto);
    CustomerDTO updateCustomer(CustomerRequestDTO dto);

    String getCustomerNameByUuid(UUID uuid);
    Map<UUID, String> getCustomerNamesByUuids(Set<UUID> customerUuids);
    void updateExpiryAfterPayment(UUID customerUuid, UUID planUuid);
    CustomerBMIDTO getBMI(UUID uuid);
}
