package com.lht.repositories;

import com.lht.pojo.Salary;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;

public interface SalaryRepository extends JpaRepository<Salary, UUID>, JpaSpecificationExecutor<Salary>{

    List<Salary> findByStaffUuid(UUID staffUuid);

    boolean existsByDateBetween(LocalDate start, LocalDate end);

    List<Salary> findByDateBetween(LocalDate start, LocalDate end);

    void deleteByStaffUuid(UUID staffUuid);

    @Query("""
    SELECT s.date, SUM(s.price)
    FROM Salary s
    WHERE YEAR(s.date) = :year
    GROUP BY s.date
    ORDER BY s.date
    """)
    List<Object[]> getDailyExpense(int year);

    @Query("""
    SELECT MONTH(s.date), SUM(s.price)
    FROM Salary s
    WHERE YEAR(s.date) = :year
    GROUP BY MONTH(s.date)
    ORDER BY MONTH(s.date)
    """)
    List<Object[]> getMonthlyExpense(int year);

}
