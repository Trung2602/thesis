package com.lht.controllers.api;

import com.lht.dto.*;
import com.lht.component.JwtUtils;
import com.lht.pojo.Account;
import com.lht.services.AccountService;
import com.lht.services.CustomerService;
import com.lht.services.MailService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class ApiAuthController {

    private final AccountService accountService;
    private final CustomerService customerService;
    private final MailService mailService;

    @Autowired
    private JwtUtils jwtUtils;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequestDTO request) {

        if (request.getMail() == null || request.getPassword() == null) {
            return ResponseEntity.badRequest().body("Mail hoặc password không được để trống");
        }

        Account account = accountService.authenticate(request.getMail(), request.getPassword());
        if (account == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Sai thông tin đăng nhập");
        }

        try {
            String token = jwtUtils.generateToken(account.getMail(), account.getRole().name(), account.getUuid());
            LoginResponseDTO response = LoginResponseDTO.builder()
                    .uuid(account.getUuid())
                    .mail(account.getMail())
                    .role(account.getRole().name())
                    .token(token)
                    .build();

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Lỗi khi tạo JWT");
        }
    }

    private final Map<String, VerifyCustomerDTO> pendingRegistrations = new ConcurrentHashMap<>();
    @PostMapping("/register")
    public ResponseEntity<?> register(@ModelAttribute CustomerRequestDTO dto, @RequestPart(value = "image", required = false) MultipartFile file) {
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

    @PostMapping("/verify/otp")
    public ResponseEntity<?> verifyOtp(@RequestBody OtpRequest request) {
        VerifyCustomerDTO pending = pendingRegistrations.get(request.getMail());
        if (pending == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Không tìm thấy yêu cầu đăng ký"));
        }
        if (pending.isExpired()) {
            pendingRegistrations.remove(request.getMail());
            return ResponseEntity.badRequest().body(Map.of("error", "OTP đã hết hạn"));
        }
        if (pending.getOtp() != request.getOtp()) {
            return ResponseEntity.badRequest().body(Map.of("error", "OTP không hợp lệ"));
        }
        // OTP đúng -> tạo customer
        CustomerDTO saved = customerService.createCustomer(
                pending.getDto(),
                pending.getFile()
        );
        pendingRegistrations.remove(request.getMail());
        mailService.sendWelcomeMail(request.getMail());
        return ResponseEntity.ok(saved);
    }
}
