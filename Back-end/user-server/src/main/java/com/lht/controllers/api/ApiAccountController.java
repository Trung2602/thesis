package com.lht.controllers.api;

import com.lht.dto.*;
import com.lht.pojo.Account;
import com.lht.services.AccountService;
import com.lht.jwt.JwtUtils;
import java.security.Principal;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/account")
@RequiredArgsConstructor
public class ApiAccountController {

    private final AccountService accountService;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/update") //name, avatar, birthday, gender
    public ResponseEntity<?> updateAccount(
            @ModelAttribute AccountDTO dto,
            @RequestPart(value = "image", required = false) MultipartFile file,
            @RequestHeader("Authorization") String authHeader) {

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token không hợp lệ");
        }

        String token = authHeader.substring(7);
        String mail;

        try {
            mail = JwtUtils.validateTokenAndGetMail(token);
            if (mail == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token không hợp lệ");
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token không hợp lệ");
        }

        AccountDTO updated = accountService.updateProfile(mail, dto, file);

        return ResponseEntity.ok(updated);
    }

    @DeleteMapping
    public ResponseEntity<?> deleteAccount(@RequestHeader("Authorization") String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token không hợp lệ");
        }
        String token = authHeader.substring(7);
        String mail;
        try {
            mail = JwtUtils.validateTokenAndGetMail(token);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token không hợp lệ");
        }
        Account account = accountService.getAccountByMail(mail);
        if (account == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Tài khoản không tồn tại");
        }
        accountService.deleteAccount(account.getUuid());
        return ResponseEntity.ok("Xóa tài khoản thành công");
    }

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
            String token = JwtUtils.generateToken(account.getMail(), account.getRole().name());
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

    @GetMapping("/me")
    public ResponseEntity<?> getCurrentAccount(Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Chưa đăng nhập");
        }
        String mail = principal.getName();
        AccountDTO dto = accountService.getCurrentAccountDTO(mail);

        return ResponseEntity.ok(dto);
    }

    @PostMapping("/verify-password")
    public ResponseEntity<?> verifyPassword(@RequestBody PasswordDTO request,
            @RequestHeader("Authorization") String authHeader) {
        // Kiểm tra Authorization header
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token không hợp lệ");
        }

        String token = authHeader.substring(7);
        String mail;
        try {
            mail = JwtUtils.validateTokenAndGetMail(token);
            if (mail == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token không hợp lệ");
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token không hợp lệ");
        }

        Account account = accountService.getAccountByMail(mail);
        if (account == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Tài khoản không tồn tại");
        }

        if (passwordEncoder.matches(request.getPassword(), account.getPasswordHash())) {
            return ResponseEntity.ok("Mật khẩu chính xác");
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Mật khẩu không đúng");
        }
    }

    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody PasswordDTO request,
            @RequestHeader("Authorization") String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token không hợp lệ");
        }
        String token = authHeader.substring(7);
        String mail;
        try {
            mail = JwtUtils.validateTokenAndGetMail(token);
            if (mail == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token đã hết hạn hoặc không hợp lệ");
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token không hợp lệ");
        }

        accountService.changePassword(mail, request);

        return ResponseEntity.ok("Mật khẩu đã được cập nhật thành công");
    }
}
