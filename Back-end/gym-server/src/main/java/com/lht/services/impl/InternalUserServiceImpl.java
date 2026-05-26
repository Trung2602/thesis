package com.lht.services.impl;

import com.lht.services.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class InternalUserServiceImpl implements InternalUserService{
    private final StaffDayOffService staffDayOffService;
    private final StaffScheduleService staffScheduleService;
    private final SalaryService salaryService;
    private final CustomerScheduleService customerScheduleService;
    private final PayCustomerService payCustomerService;

    @Override
    public void deleteRelatedData(UUID uuid, String role) {
        switch (role) {
            case "STAFF" -> {
                staffDayOffService.deleteByStaffUuid(uuid);
                staffScheduleService.deleteByStaffUuid(uuid);
                customerScheduleService.deleteByStaffUuid(uuid);
                salaryService.deleteByStaffUuid(uuid);
            }
            case "CUSTOMER" -> {
                customerScheduleService.deleteByCustomerUuid(uuid);
                payCustomerService.deleteByCustomerUuid(uuid);
            }
        }
    }
}
