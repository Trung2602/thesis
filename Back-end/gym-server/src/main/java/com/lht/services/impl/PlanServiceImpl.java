package com.lht.services.impl;

import com.lht.dto.PlanDTO;
import com.lht.pojo.Plan;
import com.lht.repositories.PlanRepository;
import com.lht.services.PlanService;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;

import java.util.*;

import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
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
public class PlanServiceImpl implements PlanService {

    private final PlanRepository planRepository;

    private PlanDTO mapToDTO(Plan p) {
        if (p == null) return null;

        return new PlanDTO(
                p.getUuid(),
                p.getName(),
                p.getPrice(),
                p.getDurationDays(),
                p.getDescription()
        );
    }

    public List<PlanDTO> getAllPlans() {
        return planRepository.findAll().stream()
                .map(this::mapToDTO)
                .toList();
    }

    @Override
    public PlanDTO getPlanByUuid(UUID uuid) {
        return planRepository.findById(uuid)
                .map(this::mapToDTO)
                .orElse(null);
    }

    @Override
    public Plan getByUuid(UUID uuid) {
        return planRepository.findById(uuid).orElse(null);
    }

    @Override
    public Plan addOrUpdatePlan(Plan p) {
        if (p.getName() == null || p.getName().isEmpty()) {
            p.setName("Gói cơ bản");
        }
        if (p.getDescription() == null || p.getDescription().isEmpty()) {
            p.setDescription("Gói tập cơ bản cho người mới");
        }
        if (p.getPrice() == null || p.getPrice() <= 0) {
            p.setPrice(300000);
        }
        if (p.getDurationDays() == null || p.getDurationDays() <= 0) {
            p.setDurationDays(30);
        }

        return planRepository.save(p);
    }

    @Override
    public boolean deletePlan(UUID uuid) {
        if (planRepository.existsById(uuid)) {
            planRepository.deleteById(uuid);
            return true;
        }
        return false;
    }

    @Override
    public List<PlanDTO> getPlans(Map<String, String> params) {
        Specification<Plan> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (params.containsKey("uuid") && params.get("uuid") != null && !params.get("uuid").isBlank()) {
                predicates.add(cb.equal(root.get("uuid"), UUID.fromString(params.get("uuid"))));
            }

            if (params.containsKey("name") && params.get("name") != null && !params.get("name").isBlank()) {
                predicates.add(cb.like(cb.lower(root.get("name")), "%" + params.get("name").toLowerCase() + "%"));
            }

            if (params.containsKey("price") && params.get("price") != null && !params.get("price").isBlank()) {
                try {
                    Integer price = Integer.parseInt(params.get("price"));
                    predicates.add(cb.equal(root.get("price"), price));
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("Invalid price format");
                }
            }

            if (params.containsKey("durationDays") && params.get("durationDays") != null && !params.get("durationDays").isBlank()) {
                try {
                    Integer duration = Integer.parseInt(params.get("durationDays"));
                    predicates.add(cb.equal(root.get("durationDays"), duration));
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("Invalid durationDays format");
                }
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };

        return planRepository.findAll(spec).stream()
                .map(this::mapToDTO)
                .toList();
    }

    @Override
    public Page<PlanDTO> getAllSort(String sortField, String sortDir, int page, int size) {
        Sort sort = sortDir.equalsIgnoreCase("asc")
                ? Sort.by(sortField).ascending()
                : Sort.by(sortField).descending();
        Pageable pageable = PageRequest.of(page, size, sort);

        return planRepository.findAll(pageable).map(this::mapToDTO);
    }

    @Override
    public Integer getDurationDays(UUID uuid) {
        return this.getPlanByUuid(uuid).getDurationDays();
    }
}
