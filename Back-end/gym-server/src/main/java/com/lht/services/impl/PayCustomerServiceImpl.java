package com.lht.services.impl;

import com.lht.client.InternalUserClient;
import com.lht.dto.PayCustomerDTO;
import com.lht.dto.PlanDTO;
import com.lht.pojo.PayCustomer;
import com.lht.pojo.Plan;
import com.lht.pojo.StatusType;
import com.lht.repositories.PayCustomerRepository;
import com.lht.repositories.PlanRepository;
import com.lht.services.PayCustomerService;

import com.lht.services.PlanService;
import jakarta.persistence.criteria.Predicate;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
@RequiredArgsConstructor
public class  PayCustomerServiceImpl implements PayCustomerService {

    private final PayCustomerRepository payCustomerRepository;
    private final InternalUserClient internalUserClient;
    private final PlanService planService;
    private final PlanRepository planRepository;

    private PayCustomerDTO mapToDTO(PayCustomer p) {
        PayCustomerDTO dto = new PayCustomerDTO();

        dto.setUuid(p.getUuid());
        dto.setDate(p.getDate());
        dto.setCustomerUuid(p.getCustomerUuid());
        dto.setPlanUuid(p.getPlanUuid());
        dto.setTxnRef(p.getTxnRef());
        dto.setBankCode(p.getBankCode());
        dto.setStatus(p.getStatus().name());
        dto.setCustomerName(internalUserClient.getCustomerNameByUuid(p.getCustomerUuid()));
        Optional<Plan> planOpt = planRepository.findById(p.getPlanUuid());
        planOpt.ifPresent(plan -> {
            dto.setPlanName(plan.getName());
            dto.setPrice(plan.getPrice());
        });

        return dto;
    }

    private List<PayCustomerDTO> mapToDTO(List<PayCustomer> payments) {
        if (payments.isEmpty()) {
            return List.of();
        }
        Set<UUID> customerUuids = payments.stream()
                .map(PayCustomer::getCustomerUuid)
                .collect(Collectors.toSet());
        Set<UUID> planUuids = payments.stream()
                .map(PayCustomer::getPlanUuid)
                .collect(Collectors.toSet());
        Map<UUID, String> customerMap = internalUserClient.getCustomerNamesByUuids(customerUuids);
        List<Plan> plans = planRepository.findAllById(planUuids);
        Map<UUID, Plan> planMap = plans.stream().collect(Collectors.toMap(Plan::getUuid, p -> p));

        return payments.stream().map(p -> {
                Plan plan = planMap.get(p.getPlanUuid());

                return PayCustomerDTO.builder()
                        .uuid(p.getUuid())
                        .date(p.getDate())
                        .customerUuid(p.getCustomerUuid())
                        .customerName(customerMap.getOrDefault(p.getCustomerUuid(), "Unknown"))
                        .planUuid(p.getPlanUuid())
                        .planName(plan != null ? plan.getName() : "Unknown")
                        .price(plan != null ? plan.getPrice() : 0)
                        .txnRef(p.getTxnRef())
                        .bankCode(p.getBankCode())
                        .status(p.getStatus().name())
                        .build();
                })
                .toList();
    }

    private PayCustomer toEntity(PayCustomerDTO dto) {
        PayCustomer p = new PayCustomer();
        p.setUuid(dto.getUuid());
        p.setDate(dto.getDate());
        p.setCustomerUuid(dto.getCustomerUuid());
        p.setPlanUuid(dto.getPlanUuid());
        p.setTxnRef(dto.getTxnRef());
        p.setBankCode(dto.getBankCode());
        if (dto.getStatus() != null) {
            p.setStatus(StatusType.valueOf(dto.getStatus()));
        }
        return p;
    }

    @Override
    public List<PayCustomerDTO> getAllPayCustomers() {
        List<PayCustomer> list = payCustomerRepository.findAll();
        return mapToDTO(list);
    }

    @Override
    public PayCustomerDTO getPayCustomerByUuid(UUID uuid) {
        PayCustomer p = payCustomerRepository.findById(uuid).orElse(null);
        return p != null ? mapToDTO(p) : null;
    }

    @Override
    public PayCustomer getByUuid(UUID uuid) {
        return payCustomerRepository.findById(uuid).orElse(null);
    }

    @Override
    public PayCustomerDTO addOrUpdatePayCustomer(PayCustomerDTO dto) {
        if (dto.getCustomerUuid() == null) {
            throw new IllegalArgumentException("Customer không được để trống");
        }
        boolean customerExists = internalUserClient.existsByUuid(dto.getCustomerUuid());
        if (!customerExists) {
            throw new IllegalArgumentException("Customer không tồn tại");
        }

        if (dto.getPlanUuid() == null) {
            throw new IllegalArgumentException("Plan không được để trống");
        }
        if (!planRepository.existsById(dto.getPlanUuid())) {
            throw new IllegalArgumentException("Plan không tồn tại");
        }

        PayCustomer entity = toEntity(dto);
        if (entity.getUuid() == null) {
            if (entity.getStatus() == null) {
                entity.setStatus(StatusType.PENDING);
            }
        } else {
            PayCustomer old = payCustomerRepository.findById(entity.getUuid()).orElseThrow(() -> new RuntimeException("PayCustomer not found"));
            entity.setTxnRef(old.getTxnRef());
            entity.setBankCode(old.getBankCode());
            entity.setStatus(old.getStatus());
        }

        PayCustomer saved = payCustomerRepository.save(entity);
        return mapToDTO(saved);
    }

    @Override
    public PayCustomer createPayCustomer(PayCustomer entity) {

        if (entity.getCustomerUuid() == null) {
            throw new IllegalArgumentException("Customer không được để trống");
        }

        boolean customerExists = internalUserClient.existsByUuid(entity.getCustomerUuid());
        if (!customerExists) {
            throw new IllegalArgumentException("Customer không tồn tại");
        }

        if (entity.getPlanUuid() == null) {
            throw new IllegalArgumentException("Plan không được để trống");
        }

        if (!planRepository.existsById(entity.getPlanUuid())) {
            throw new IllegalArgumentException("Plan không tồn tại");
        }

        // tạo mới
        if (entity.getStatus() == null) {
            entity.setStatus(StatusType.PENDING);
        }

        return payCustomerRepository.save(entity);
    }

    @Override
    public boolean deletePayCustomer(UUID uuid) {
        if (payCustomerRepository.existsById(uuid)) {
            payCustomerRepository.deleteById(uuid);
            return true;
        }
        return false;
    }

    @Override
    public List<PayCustomerDTO> getPayCustomers(Map<String, String> params) {
        Specification<PayCustomer> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (params.containsKey("uuid") && !params.get("uuid").isBlank()) {
                predicates.add(cb.equal(root.get("uuid"), UUID.fromString(params.get("uuid"))));
            }

            if (params.containsKey("customerUuid") && !params.get("customerUuid").isBlank()) {
                predicates.add(cb.equal(root.get("customerUuid"), UUID.fromString(params.get("customerUuid"))));
            }

            if (params.containsKey("planUuid") && !params.get("planUuid").isBlank()) {
                predicates.add(cb.equal(root.get("planUuid"), UUID.fromString(params.get("planUuid"))));
            }

            if (params.containsKey("txnRef") && !params.get("txnRef").isBlank()) {
                predicates.add(cb.equal(root.get("txnRef"), params.get("txnRef")));
            }

            if (params.containsKey("bankCode") && !params.get("bankCode").isBlank()) {
                predicates.add(cb.equal(root.get("bankCode"), params.get("bankCode")));
            }

            if (params.containsKey("status") && !params.get("status").isBlank()) {
                try {
                    StatusType status = StatusType.valueOf(params.get("status"));
                    predicates.add(cb.equal(root.get("status"), status));
                } catch (IllegalArgumentException e) {
                    throw new IllegalArgumentException("Invalid status value");
                }
            }

            if (params.containsKey("date") && !params.get("date").isBlank()) {
                LocalDate date = LocalDate.parse(params.get("date"));
                predicates.add(cb.equal(root.get("date"), date));
            }

            if (params.containsKey("startDate") &&
                    params.containsKey("endDate") &&
                    !params.get("startDate").isBlank() &&
                    !params.get("endDate").isBlank()) {

                LocalDate start = LocalDate.parse(params.get("startDate"));
                LocalDate end = LocalDate.parse(params.get("endDate"));

                predicates.add(cb.between(root.get("date"), start, end));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
        List<PayCustomer> result = payCustomerRepository.findAll(spec);

        return mapToDTO(result);
    }

    @Override
    public Page<PayCustomerDTO> getAllSort(String sortField, String sortDir, int page, int size) {
        Sort sort = sortDir.equalsIgnoreCase("asc")
                ? Sort.by(sortField).ascending()
                : Sort.by(sortField).descending();
        Pageable pageable = PageRequest.of(page, size, sort);
        Page<PayCustomer> result = payCustomerRepository.findAll(pageable);

        return result.map(this::mapToDTO);
    }

    @Override
    public List<PayCustomerDTO> getPayCustomerByCustomerUuid(UUID uuid) {
        List<PayCustomer> list = payCustomerRepository.findByCustomerUuid(uuid);
        return mapToDTO(list);
    }

    @Override
    public void updatePaymentStatus(PayCustomer pay, String txnRef, StatusType status, String bankCode) {
        if (pay != null) {
            pay.setTxnRef(txnRef);
            pay.setBankCode(bankCode);
            pay.setStatus(status);

            payCustomerRepository.save(pay);
        }
    }

}
