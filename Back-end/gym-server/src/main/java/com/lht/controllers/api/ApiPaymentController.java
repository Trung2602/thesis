package com.lht.controllers.api;

import com.lht.pojo.StatusType;
import com.lht.services.PaymentService;
import jakarta.servlet.http.HttpServletRequest;

import java.util.*;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/gym")
@RequiredArgsConstructor
public class ApiPaymentController {
    private final PaymentService paymentService;

    @PostMapping("/payment/create")
    public ResponseEntity<?> createPayment(@RequestBody Map<String, String> body, HttpServletRequest request) throws Exception {
        UUID planUuid = UUID.fromString(body.get("planUuid"));
        String mail = SecurityContextHolder.getContext().getAuthentication().getName();
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty()) {
            ip = request.getRemoteAddr();
        } else {
            ip = ip.split(",")[0].trim();
        }
        String paymentUrl = paymentService.createPaymentUrl(planUuid, mail, ip);
        return ResponseEntity.ok(Map.of("paymentUrl", paymentUrl));
    }

    @GetMapping("/payment/return")
    public ResponseEntity<?> handleReturn(@RequestParam Map<String, String> params) throws Exception {
        StatusType status = paymentService.handleReturn(params);
        return ResponseEntity.ok(Map.of("status", status));
    }
}
