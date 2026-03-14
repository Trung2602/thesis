package com.lht.services;

import com.lht.dto.SalaryDTO;
import com.lht.pojo.Salary;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.data.domain.Page;

public interface SalaryService {

    List<SalaryDTO> getAllSalaries();

    SalaryDTO getSalaryByUuid(UUID uuid);

    SalaryDTO addOrUpdateSalary(SalaryDTO dto);

    boolean deleteSalary(UUID uuid);

    List<SalaryDTO> getSalaries(Map<String, String> params);

    Page<SalaryDTO> getAllSort(String sortField, String sortDir, int page, int size);

    List<SalaryDTO> getSalaryByStaffUuid(UUID uuid);


    void calculateMonthlySalaries(int month, int year);
    
    boolean existsSalaryForMonth(int month, int year);

    List<SalaryDTO> getSalaryByMonth(int month, int year);
}
