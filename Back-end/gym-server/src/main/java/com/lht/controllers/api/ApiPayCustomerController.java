package com.lht.controllers.api;

import com.lht.dto.PayCustomerDTO;
import com.lht.services.PayCustomerService;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/pay-customers")
@RequiredArgsConstructor
public class ApiPayCustomerController {

    private final PayCustomerService payCustomerService;

    @GetMapping
    public ResponseEntity<List<PayCustomerDTO>> getAllPayCustomers() {
        return ResponseEntity.ok(payCustomerService.getAllPayCustomers());
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<PayCustomerDTO> getPayCustomerByUuid(@PathVariable UUID uuid) {
        PayCustomerDTO dto = payCustomerService.getPayCustomerByUuid(uuid);

        if (dto == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(dto);
    }

    @GetMapping("/filter")
    public ResponseEntity<List<PayCustomerDTO>> getPayCustomersFilter(@RequestParam Map<String, String> params) {
        return ResponseEntity.ok(payCustomerService.getPayCustomers(params));
    }

    @GetMapping("/sort")
    public ResponseEntity<Page<PayCustomerDTO>> getPayCustomersSort(
            @RequestParam(defaultValue = "date") String sortField,
            @RequestParam(defaultValue = "asc") String sortDir,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        return ResponseEntity.ok(payCustomerService.getAllSort(sortField, sortDir, page, size));
    }

    @GetMapping("/customer/{uuid}")
    public ResponseEntity<List<PayCustomerDTO>> getByCustomerUuid(@PathVariable UUID uuid) {
        return ResponseEntity.ok(
                payCustomerService.getPayCustomerByCustomerUuid(uuid)
        );
    }

    @PostMapping
    public ResponseEntity<?> addOrUpdatePayCustomer(@RequestBody PayCustomerDTO dto) {
        try {
            PayCustomerDTO result = payCustomerService.addOrUpdatePayCustomer(dto);
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> deletePayCustomer(@PathVariable UUID uuid) {
        boolean deleted = payCustomerService.deletePayCustomer(uuid);
        if (deleted) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
