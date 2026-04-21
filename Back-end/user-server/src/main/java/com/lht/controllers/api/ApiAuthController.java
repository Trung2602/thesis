package com.lht.controllers.api;

import com.lht.dto.*;
import com.lht.services.AccountService;
import com.lht.services.CustomerService;
import com.lht.services.MailService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@RestController
@RequestMapping("/api/v1/user/auth")
@RequiredArgsConstructor
public class ApiAuthController {

    private final AccountService accountService;
    private final CustomerService customerService;
    private final MailService mailService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequestDTO request) throws Exception {
        LoginResponseDTO response = accountService.login(request);
        return ResponseEntity.ok(response);
    }

    private final Map<String, VerifyCustomerDTO> pendingRegistrations = new ConcurrentHashMap<>();
    @PostMapping("/register")
    public ResponseEntity<?> register(@ModelAttribute CustomerRequestDTO dto, @RequestPart(value = "image", required = false) MultipartFile file) {
        String check = accountService.checkDuplicate(dto.getMail());
        if (!"OK".equals(check)) {
            return ResponseEntity.badRequest().body(Map.of("error", check));
        }
        int otp = 100000 + new Random().nextInt(900000);
        mailService.sendOTP(dto.getMail(), otp);
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
        CustomerDTO saved = customerService.createCustomerAndAvatar(
                pending.getDto(),
                pending.getFile()
        );
        pendingRegistrations.remove(request.getMail());
        mailService.sendWelcomeMail(request.getMail());
        return ResponseEntity.ok(saved);
    }
}
