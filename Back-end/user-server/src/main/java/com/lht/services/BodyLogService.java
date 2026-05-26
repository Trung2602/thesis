package com.lht.services;

import com.lht.dto.BodyLogDTO;
import java.util.List;
import java.util.UUID;

public interface BodyLogService {
    BodyLogDTO create(BodyLogDTO dto);
    BodyLogDTO update(UUID uuid, BodyLogDTO dto);
    void delete(UUID uuid);
    List<BodyLogDTO> getHistory(UUID customerUuid);
    List<BodyLogDTO> getRecentHistory(UUID customerUuid, int limit);
}