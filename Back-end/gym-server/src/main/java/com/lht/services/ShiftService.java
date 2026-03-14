package com.lht.services;

import com.lht.dto.ShiftDTO;
import com.lht.pojo.Shift;

import java.util.*;

import org.springframework.data.domain.Page;

public interface ShiftService {

    List<ShiftDTO> getAllShifts();

    ShiftDTO getShiftByUuid(UUID uuid);

    ShiftDTO addOrUpdateShift(ShiftDTO dto);

    boolean deleteShift(UUID uuid);

    List<ShiftDTO> getShifts(Map<String, String> params);

    Page<ShiftDTO> getAllSort(String sortField, String sortDir, int page, int size);

}
