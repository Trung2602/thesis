package com.lht.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record InternalUserResponse(
        UUID uuid,
        String role,
        BigDecimal baseSalary,
        String staffType
) {}
