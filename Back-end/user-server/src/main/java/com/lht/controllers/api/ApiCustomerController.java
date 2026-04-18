package com.lht.controllers.api;

import com.lht.dto.CustomerDTO;
import com.lht.dto.CustomerRequestDTO;
import com.lht.services.CustomerService;

import java.util.UUID;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/user/customers")
@RequiredArgsConstructor
public class ApiCustomerController {
    private final CustomerService customerService;

    @GetMapping("/{uuid}")
    public ResponseEntity<?> getCustomer(@PathVariable UUID uuid) {
        return ResponseEntity.ok(customerService.getCustomerByUuid(uuid));
    }

    @PostMapping
    public ResponseEntity<?> createCustomer(@ModelAttribute CustomerRequestDTO dto,
                                            @RequestPart(value = "image", required = false) MultipartFile file) {
        return ResponseEntity.ok(customerService.createCustomer(dto, file));
    }

    @PatchMapping
    public ResponseEntity<?> updateCustomer(@ModelAttribute CustomerDTO dto,
                                            @RequestPart(value = "image", required = false) MultipartFile file)
    {
        return ResponseEntity.ok(customerService.updateCustomer(dto, file));
    }
}
