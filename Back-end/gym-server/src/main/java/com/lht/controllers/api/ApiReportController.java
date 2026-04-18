package com.lht.controllers.api;

import com.lht.services.ReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/gym/report")
@RequiredArgsConstructor
public class ApiReportController {
    private final ReportService reportService;

    @GetMapping
    public ResponseEntity<?> getReport(
            @RequestParam String type,
            @RequestParam int month,
            @RequestParam int year,
            @RequestParam(defaultValue = "1") int quarter
    ) {
        return ResponseEntity.ok(reportService.getReport(type, month, year, quarter));
    }
}
