package com.lht.services.impl;

import com.lht.pojo.Facility;
import com.lht.repositories.FacilityRepository;
import com.lht.services.FacilityService;
import jakarta.persistence.criteria.Predicate;

import java.util.*;
import java.util.stream.Collectors;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
@RequiredArgsConstructor
public class FacilityServiceImpl implements FacilityService {

    private final FacilityRepository facilityRepository;

    @Override
    public List<Facility> getAllFacilities() {
        return facilityRepository.findAll();
    }

    @Override
    public Facility getFacilityByUuid(UUID uuid) {
        return facilityRepository.findById(uuid).orElse(null);
    }

    @Override
    public Facility addOrUpdateFacility(Facility f) {
        if (f.getName() == null || f.getName().isEmpty()) {
            f.setName("Cơ sở chưa đặt tên");
        }
        if (f.getAddress() == null || f.getAddress().isEmpty()) {
            f.setAddress("Địa chỉ chưa xác định");
        }

        return facilityRepository.save(f);
    }

    @Override
    public boolean deleteFacility(UUID uuid) {
        if (facilityRepository.existsById(uuid)) {
            facilityRepository.deleteById(uuid);
            return true;
        }
        return false;
    }

    @Override
    public List<Facility> getFacilities(Map<String, String> params) {
        Specification<Facility> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (params.containsKey("uuid") && params.get("uuid") != null && !params.get("uuid").isBlank()) {
                predicates.add(cb.equal(root.get("uuid"), UUID.fromString(params.get("uuid"))));
            }

            if (params.containsKey("name") && params.get("name") != null && !params.get("name").isBlank()) {
                predicates.add(cb.like(cb.lower(root.get("name")), "%" + params.get("name").toLowerCase() + "%"));
            }

            if (params.containsKey("address") && params.get("address") != null && !params.get("address").isBlank()) {
                predicates.add(cb.like(cb.lower(root.get("address")), "%" + params.get("address").toLowerCase() + "%"));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };

        return facilityRepository.findAll(spec);
    }

    @Override
    public List<Facility> getAllSort(String sortField, String sortDir) {
        Sort sort = sortDir.equalsIgnoreCase("asc")
                ? Sort.by(sortField).ascending()
                : Sort.by(sortField).descending();
        return facilityRepository.findAll(sort);
    }

    @Override
    public Map<UUID, String> getFacilityNamesByUuids(Set<UUID> uuids) {
        return facilityRepository.findAllById(uuids)
                .stream()
                .collect(Collectors.toMap(
                        Facility::getUuid,
                        Facility::getName,
                        (existing, replacement) -> existing
                ));
    }
}
