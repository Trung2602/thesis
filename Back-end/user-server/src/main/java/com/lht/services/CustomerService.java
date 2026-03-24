package com.lht.services;

import com.lht.dto.CustomerBMIDTO;
import com.lht.dto.CustomerDTO;
import com.lht.dto.CustomerRequestDTO;
import com.lht.pojo.Customer;
import org.springframework.web.multipart.MultipartFile;

import java.util.*;

public interface CustomerService {

    List<CustomerDTO> getAllCustomers();
    CustomerDTO getCustomerByUuid(UUID uuid);
    Customer getByUuid(UUID uuid);
    List<CustomerDTO> getCustomers(Map<String, String> params);
    CustomerDTO createCustomer(CustomerRequestDTO dto, MultipartFile file);
    CustomerDTO updateCustomer(CustomerDTO dto, MultipartFile file);
    boolean deleteCustomer(UUID uuid);

    String getCustomerNameByUuid(UUID uuid);
    Map<UUID, String> getCustomerNamesByUuids(Set<UUID> customerUuids);
    void updateExpiryAfterPayment(UUID customerUuid, UUID planUuid);
    CustomerBMIDTO getBMI(UUID uuid);
}
