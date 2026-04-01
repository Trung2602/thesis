package com.lht.services.impl;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.lht.client.InternalGymClient;
import com.lht.dto.CustomerBMIDTO;
import com.lht.dto.CustomerDTO;
import com.lht.dto.CustomerRequestDTO;
import com.lht.pojo.AccountRole;
import com.lht.pojo.Customer;
import com.lht.pojo.GenderType;
import com.lht.repositories.CustomerRepository;
import com.lht.services.CustomerService;

import java.time.LocalDate;
import java.util.*;

import jakarta.persistence.criteria.Predicate;
import java.io.IOException;
import java.util.stream.Collectors;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@Transactional
@RequiredArgsConstructor
public class CustomerServiceImpl implements CustomerService {

    private final CustomerRepository customerRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final InternalGymClient internalGymClient;

    @Autowired
    private Cloudinary cloudinary;

    private CustomerDTO mapToDTO(Customer c) {
        CustomerDTO dto = new CustomerDTO();

        dto.setUuid(c.getUuid());
        dto.setMail(c.getMail());
        dto.setName(c.getName());

        dto.setRole(c.getRole() != null ? c.getRole().name() : null);

        dto.setAvatar(c.getAvatar());
        dto.setBirthday(c.getBirthday());

        dto.setGender(c.getGender() != null ? c.getGender().name() : null);

        dto.setIsActive(c.getIsActive());
        dto.setWeight(c.getWeight());
        dto.setHeight(c.getHeight());
        dto.setExpiryDate(c.getExpiryDate());

        return dto;
    }

    private List<CustomerDTO> mapToDTO(List<Customer> customers) {
        if (customers.isEmpty()) {
            return List.of();
        }

        return customers.stream()
                .map(c -> CustomerDTO.builder()
                        .uuid(c.getUuid())
                        .mail(c.getMail())
                        .name(c.getName())
                        .role(c.getRole() != null ? c.getRole().name() : null)
                        .avatar(c.getAvatar())
                        .birthday(c.getBirthday())
                        .gender(c.getGender() != null ? c.getGender().name() : null)
                        .isActive(c.getIsActive())
                        .weight(c.getWeight())
                        .height(c.getHeight())
                        .expiryDate(c.getExpiryDate())
                        .build())
                .collect(Collectors.toList());
    }

    private Customer toEntity(CustomerDTO dto) {
        Customer c = new Customer();

        c.setUuid(dto.getUuid());
        c.setMail(dto.getMail());
        c.setName(dto.getName());
        if (dto.getRole() != null) {
            c.setRole(AccountRole.valueOf(dto.getRole()));
        }
        c.setAvatar(dto.getAvatar());
        c.setBirthday(dto.getBirthday());
        if (dto.getGender() != null) {
            c.setGender(GenderType.valueOf(dto.getGender()));
        }
        c.setIsActive(dto.getIsActive());
        c.setWeight(dto.getWeight());
        c.setHeight(dto.getHeight());
        c.setExpiryDate(dto.getExpiryDate());
        return c;
    }

    @Override
    public List<CustomerDTO> getAllCustomers() {
        return mapToDTO(customerRepository.findAll());
    }

    @Override
    public CustomerDTO getCustomerByUuid(UUID uuid) {
        return customerRepository.findById(uuid).map(this::mapToDTO).orElse(null);
    }

    @Override
    public Customer getByUuid(UUID uuid) {
        return customerRepository.findById(uuid).orElse(null);
    }

    @Override
    public List<CustomerDTO> getCustomers(Map<String, String> params) {

        Specification<Customer> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (params.containsKey("name")) {
                predicates.add(cb.like(
                        cb.lower(root.get("name")),
                        "%" + params.get("name").toLowerCase() + "%"
                ));
            }

            if (params.containsKey("isActive")) {
                predicates.add(cb.equal(
                        root.get("isActive"),
                        Boolean.valueOf(params.get("isActive"))
                ));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };

        return mapToDTO(customerRepository.findAll(spec));
    }

    @Override
    public CustomerDTO createCustomer(CustomerRequestDTO dto, MultipartFile file) {
        Customer c = new Customer();
        c.setMail(dto.getMail());
        c.setName(dto.getName());
        c.setBirthday(dto.getBirthday());
        c.setGender(GenderType.valueOf(dto.getGender().toUpperCase()));
        c.setRole(AccountRole.CUSTOMER);
        c.setIsActive(true);
        c.setWeight(dto.getWeight());
        c.setHeight(dto.getHeight());

        if (dto.getExpiryDate() == null) {
            c.setExpiryDate(LocalDate.now().plusDays(1));
        } else {
            c.setExpiryDate(dto.getExpiryDate());
        }

        c.setPasswordHash(passwordEncoder.encode(dto.getPassword()));

        if (file != null && !file.isEmpty()) {
            try {
                Map res = cloudinary.uploader().upload(
                        file.getBytes(),
                        ObjectUtils.asMap("resource_type", "auto")
                );
                c.setAvatar(res.get("secure_url").toString());

            } catch (IOException ex) {
                ex.printStackTrace();
            }
        } else {
            c.setAvatar("https://res.cloudinary.com/dsagezboe/image/upload/v1775034161/logo_black_l0rv4p.png");
        }

        Customer saved = customerRepository.save(c);

        return mapToDTO(saved);
    }

    @Override
    public CustomerDTO updateCustomer(CustomerDTO dto, MultipartFile file) {

        Customer c = customerRepository.findById(dto.getUuid()).orElseThrow(() -> new RuntimeException("Customer không tồn tại"));

        c.setMail(dto.getMail());
        c.setName(dto.getName());
        c.setBirthday(dto.getBirthday());
        c.setWeight(dto.getWeight());
        c.setHeight(dto.getHeight());
        if (dto.getGender() != null) {
            c.setGender(GenderType.valueOf(dto.getGender()));
        }
        if (dto.getIsActive() != null) {
            c.setIsActive(dto.getIsActive());
        }
        c.setExpiryDate(dto.getExpiryDate());

        if (file != null && !file.isEmpty()) {
            try {
                Map res = cloudinary.uploader().upload(
                        file.getBytes(),
                        ObjectUtils.asMap("resource_type", "auto")
                );

                c.setAvatar(res.get("secure_url").toString());

            } catch (IOException ex) {
                ex.printStackTrace();
            }
        } else {
            c.setAvatar(dto.getAvatar());
        }

        Customer saved = customerRepository.save(c);

        return mapToDTO(saved);
    }

    @Override
    public boolean deleteCustomer(UUID uuid) {
        if (customerRepository.existsById(uuid)) {
            customerRepository.deleteById(uuid);
            return true;
        }
        return false;
    }

    @Override
    public String getCustomerNameByUuid(UUID uuid) {
        return customerRepository.findById(uuid).map(Customer::getName).orElse("Unknown");
    }

    @Override
    public Map<UUID, String> getCustomerNamesByUuids(Set<UUID> customerUuids) {
        List<Customer> customers = customerRepository.findAllById(customerUuids);
        return customers.stream()
                .collect(Collectors.toMap(
                        Customer::getUuid,
                        Customer::getName
                ));
    }

    @Override
    public void updateExpiryAfterPayment(UUID customerUuid, UUID planUuid) {

        Customer customer = customerRepository.findById(customerUuid)
                .orElseThrow(() -> new RuntimeException("Customer not found"));

        LocalDate currentExpiry = customer.getExpiryDate();
        LocalDate now = LocalDate.now();

        if (currentExpiry == null) {
            currentExpiry = now;
        }

        int durationDays = internalGymClient.getDurationDays(planUuid);

        LocalDate newExpiry = currentExpiry.isBefore(now)
                ? now.plusDays(durationDays)
                : currentExpiry.plusDays(durationDays);

        customer.setExpiryDate(newExpiry);

        customerRepository.save(customer);
    }

    @Override
    public CustomerBMIDTO getBMI(UUID uuid) {

        Customer c = customerRepository.findById(uuid).orElseThrow(() -> new RuntimeException("Customer not found"));

        CustomerBMIDTO dto = new CustomerBMIDTO();
        dto.setUuid(c.getUuid());
        dto.setGender(c.getGender().toString());
        dto.setBirthday(c.getBirthday());
        dto.setHeight(c.getHeight());
        dto.setWeight(c.getWeight());

        return dto;
    }
}
