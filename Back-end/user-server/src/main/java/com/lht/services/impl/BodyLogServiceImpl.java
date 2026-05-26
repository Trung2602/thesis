package com.lht.services.impl;

import com.lht.dto.BodyLogDTO;
import com.lht.pojo.BodyLog;
import com.lht.pojo.Customer;
import com.lht.repositories.BodyLogRepository;
import com.lht.repositories.CustomerRepository;
import com.lht.services.BodyLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@Transactional
@RequiredArgsConstructor
public class BodyLogServiceImpl implements BodyLogService {

    private final BodyLogRepository bodyLogRepository;
    private final CustomerRepository customerRepository;

    private BodyLogDTO toDTO(BodyLog e) {
        return BodyLogDTO.builder()
                .uuid(e.getUuid())
                .customerUuid(e.getCustomerUuid())
                .staffUuid(e.getStaffUuid())
                .weight(e.getWeight())
                .height(e.getHeight())
                .bodyFatPercent(e.getBodyFatPercent())
                .muscleMass(e.getMuscleMass())
                .note(e.getNote())
                .loggedAt(e.getLoggedAt())
                .build();
    }

    @Override
    public BodyLogDTO create(BodyLogDTO dto) {
        BodyLog log = BodyLog.builder()
                .customerUuid(dto.getCustomerUuid())
                .staffUuid(dto.getStaffUuid())
                .weight(dto.getWeight())
                .height(dto.getHeight())
                .bodyFatPercent(dto.getBodyFatPercent())
                .muscleMass(dto.getMuscleMass())
                .note(dto.getNote())
                .build();
        BodyLog saved = bodyLogRepository.save(log);

        Customer customer = customerRepository.findById(dto.getCustomerUuid()).orElseThrow(() -> new RuntimeException("Customer not found: " + dto.getCustomerUuid().toString()));
        customer.setWeight(dto.getWeight());
        customer.setHeight(dto.getHeight());
        customerRepository.save(customer);

        return toDTO(saved);
    }

    @Override

    public BodyLogDTO update(UUID uuid, BodyLogDTO dto) {
        BodyLog log = bodyLogRepository.findById(uuid)
                .orElseThrow(() -> new RuntimeException("BodyLog not found: " + uuid));

        log.setBodyFatPercent(dto.getBodyFatPercent());
        log.setMuscleMass(dto.getMuscleMass());
        log.setNote(dto.getNote());

        boolean weightChanged = dto.getWeight() != null && dto.getWeight().compareTo(log.getWeight()) != 0;
        boolean heightChanged = dto.getHeight() != null && dto.getHeight().compareTo(log.getHeight()) != 0;

        if (weightChanged) log.setWeight(dto.getWeight());
        if (heightChanged) log.setHeight(dto.getHeight());

        BodyLog saved = bodyLogRepository.save(log);

        if (weightChanged || heightChanged) {
            bodyLogRepository
                    .findByCustomerUuidOrderByLoggedAtDesc(log.getCustomerUuid(), PageRequest.of(0, 1))
                    .stream().findFirst()
                    .filter(latest -> latest.getUuid().equals(uuid))
                    .ifPresent(latest -> {
                        Customer customer = customerRepository.findById(log.getCustomerUuid())
                                .orElseThrow(() -> new RuntimeException("Customer not found"));
                        if (weightChanged) customer.setWeight(dto.getWeight());
                        if (heightChanged) customer.setHeight(dto.getHeight());
                        customerRepository.save(customer);
                    });
        }

        return toDTO(saved);
    }

    @Override
    public void delete(UUID uuid) {
        if (!bodyLogRepository.existsById(uuid))
            throw new RuntimeException("BodyLog not found: " + uuid);
        bodyLogRepository.deleteById(uuid);
    }

    @Override
    public List<BodyLogDTO> getHistory(UUID customerUuid) {
        return bodyLogRepository.findByCustomerUuidOrderByLoggedAtDesc(customerUuid)
                .stream().map(this::toDTO).toList();
    }

    @Override
    public List<BodyLogDTO> getRecentHistory(UUID customerUuid, int limit) {
        return bodyLogRepository.findByCustomerUuidOrderByLoggedAtDesc(
                customerUuid, PageRequest.of(0, limit))
                .stream().map(this::toDTO).toList();
    }
}