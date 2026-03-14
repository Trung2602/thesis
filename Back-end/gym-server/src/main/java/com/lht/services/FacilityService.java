package com.lht.services;

import com.lht.pojo.Facility;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

public interface FacilityService {
    List<Facility> getAllFacilities();

    Facility getFacilityByUuid(UUID uuid);

    Facility addOrUpdateFacility(Facility f);

    boolean deleteFacility(UUID uuid);

    List<Facility> getFacilities(Map<String, String> params);

    List<Facility> getAllSort(String sortField, String sortDir);

    Map<UUID, String> getFacilityNamesByUuids(Set<UUID> uuids);
}
