package com.lht.repositories;

import com.lht.pojo.Salary;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface SalaryRepository extends JpaRepository<Salary, UUID>, JpaSpecificationExecutor<Salary>{

    List<Salary> findByStaffUuid(UUID staffUuid);

    boolean existsByDateBetween(LocalDate start, LocalDate end);

    List<Salary> findByDateBetween(LocalDate start, LocalDate end);
}
