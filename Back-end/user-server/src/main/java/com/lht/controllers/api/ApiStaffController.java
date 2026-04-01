package com.lht.controllers.api;

import com.lht.dto.AvailableStaffDTO;
import com.lht.services.StaffService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@RestController
@RequestMapping("/api/v1/staffs")
@RequiredArgsConstructor
public class ApiStaffController {

    private final StaffService staffService;

    @GetMapping
    public List<AvailableStaffDTO> getAvailableStaff(
            @RequestParam
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate date,
            @RequestParam
            @DateTimeFormat(iso = DateTimeFormat.ISO.TIME)
            LocalTime checkin,
            @RequestParam
            @DateTimeFormat(iso = DateTimeFormat.ISO.TIME)
            LocalTime checkout
    ) {
        return staffService.getAvailableStaff(date, checkin, checkout);
    }
}
