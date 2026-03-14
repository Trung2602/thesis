package com.lht.controllers.api;

import com.lht.dto.CustomerDTO;
import com.lht.dto.CustomerRequestDTO;
import com.lht.dto.VerifyCustomerDTO;
import com.lht.pojo.Customer;
import com.lht.services.AccountService;
import com.lht.services.CustomerService;
import com.lht.services.MailService;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/customer")
@RequiredArgsConstructor
public class ApiCustomerController {

    private final CustomerService customerService;
    private final AccountService accountService;
    private final MailService mailService;

    private final Map<String, VerifyCustomerDTO> pendingRegistrations = new ConcurrentHashMap<>();

    @PostMapping("/register")
    public ResponseEntity<?> register(@ModelAttribute CustomerRequestDTO dto,
            @RequestPart(value = "image", required = false) MultipartFile file) {
        // kiểm tra trùng mail
        String check = accountService.checkDuplicate(dto.getMail());
        if (!"OK".equals(check)) {
            return ResponseEntity.badRequest().body(Map.of("error", check));
        }
        // Sinh OTP
        int otp = 100000 + new Random().nextInt(900000);
        // Gửi mail
        mailService.sendOTP(dto.getMail(), otp);
        // Lưu tạm DTO + file + otp
        pendingRegistrations.put(dto.getMail(), new VerifyCustomerDTO(dto, file, otp));
        return ResponseEntity.ok(Map.of("message", "OTP đã được gửi tới email, có hiệu lực trong 5 phút"));
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestParam String mail, @RequestParam int otp) {

        VerifyCustomerDTO pending = pendingRegistrations.get(mail);
        if (pending == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Không tìm thấy yêu cầu đăng ký"));
        }
        if (pending.isExpired()) {
            pendingRegistrations.remove(mail);
            return ResponseEntity.badRequest().body(Map.of("error", "OTP đã hết hạn"));
        }
        if (pending.getOtp() != otp) {
            return ResponseEntity.badRequest().body(Map.of("error", "OTP không hợp lệ"));
        }
        // OTP đúng -> tạo customer
        CustomerDTO saved = customerService.createCustomer(
                pending.getDto(),
                pending.getFile()
        );
        pendingRegistrations.remove(mail);
        mailService.sendWelcomeMail(mail);
        return ResponseEntity.ok(saved);
    }
}
