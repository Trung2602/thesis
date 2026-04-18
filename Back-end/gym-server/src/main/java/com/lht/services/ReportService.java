package com.lht.services;

import com.lht.repositories.PayCustomerRepository;
import com.lht.repositories.SalaryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final SalaryRepository salaryRepo;
    private final PayCustomerRepository payRepo;

    public Map<String, Object> getReport(
            String type, int month, int year, int quarter) {

        List<Double> expense = new ArrayList<>();
        List<Double> revenue = new ArrayList<>();

        double totalExpense = 0;
        double totalRevenue = 0;

        if (type.equals("MONTH")) {
            int days = YearMonth.of(year, month).lengthOfMonth();

            Map<Integer, Double> expenseMap = new HashMap<>();
            Map<Integer, Double> revenueMap = new HashMap<>();

            for (Object[] row : salaryRepo.getDailyExpense(year)) {
                LocalDate date = (LocalDate) row[0];
                if (date.getMonthValue() == month) {
                    expenseMap.put(date.getDayOfMonth(),
                            ((Number) row[1]).doubleValue());
                }
            }

            for (Object[] row : payRepo.getDailyRevenue(year)) {
                LocalDate date = (LocalDate) row[0];
                if (date.getMonthValue() == month) {
                    revenueMap.put(date.getDayOfMonth(),
                            ((Number) row[1]).doubleValue());
                }
            }

            for (int i = 1; i <= days; i++) {
                double e = expenseMap.getOrDefault(i, 0.0);
                double r = revenueMap.getOrDefault(i, 0.0);

                expense.add(e);
                revenue.add(r);

                totalExpense += e;
                totalRevenue += r;
            }
        }

        else if (type.equals("YEAR")) {
            Map<Integer, Double> expenseMap = new HashMap<>();
            Map<Integer, Double> revenueMap = new HashMap<>();

            for (Object[] row : salaryRepo.getMonthlyExpense(year)) {
                expenseMap.put((Integer) row[0],
                        ((Number) row[1]).doubleValue());
            }

            for (Object[] row : payRepo.getMonthlyRevenue(year)) {
                revenueMap.put((Integer) row[0],
                        ((Number) row[1]).doubleValue());
            }

            for (int m = 1; m <= 12; m++) {
                double e = expenseMap.getOrDefault(m, 0.0);
                double r = revenueMap.getOrDefault(m, 0.0);

                expense.add(e);
                revenue.add(r);

                totalExpense += e;
                totalRevenue += r;
            }
        }

        else if (type.equals("QUARTER")) {
            int startMonth = (quarter - 1) * 3 + 1;

            Map<Integer, Double> expenseMap = new HashMap<>();
            Map<Integer, Double> revenueMap = new HashMap<>();

            for (Object[] row : salaryRepo.getMonthlyExpense(year)) {
                expenseMap.put((Integer) row[0],
                        ((Number) row[1]).doubleValue());
            }

            for (Object[] row : payRepo.getMonthlyRevenue(year)) {
                revenueMap.put((Integer) row[0],
                        ((Number) row[1]).doubleValue());
            }

            for (int i = 0; i < 3; i++) {
                int m = startMonth + i;

                double e = expenseMap.getOrDefault(m, 0.0);
                double r = revenueMap.getOrDefault(m, 0.0);

                expense.add(e);
                revenue.add(r);

                totalExpense += e;
                totalRevenue += r;
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("expense", expense);
        result.put("revenue", revenue);
        result.put("totalExpense", totalExpense);
        result.put("totalRevenue", totalRevenue);

        return result;
    }
}
