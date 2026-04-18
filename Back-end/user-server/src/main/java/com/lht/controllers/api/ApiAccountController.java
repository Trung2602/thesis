package com.lht.controllers.api;

import com.lht.dto.*;
import com.lht.pojo.Account;
import com.lht.services.AccountService;

import java.util.UUID;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import static com.lht.component.SecurityUtils.getCurrentUserMail;

@RestController
@RequestMapping("/api/v1/user/accounts")
@RequiredArgsConstructor
public class ApiAccountController {

    private final AccountService accountService;
    private final PasswordEncoder passwordEncoder;

    @PatchMapping("/me") //name, avatar, birthday, gender
    public ResponseEntity<?> updateAccount(
            @ModelAttribute AccountDTO dto,
            @RequestPart(value = "image", required = false) MultipartFile file) {
        String mail = getCurrentUserMail();
        AccountDTO updated = accountService.updateProfile(mail, dto, file);

        return ResponseEntity.ok(updated);
    }

    @GetMapping("/me")
    public ResponseEntity<?> getCurrentAccount() {
        AccountDTO dto = accountService.getCurrentAccountDTO();
        return ResponseEntity.ok(dto);
    }

    @PostMapping("/me/password/verify")
    public ResponseEntity<?> verifyPassword(@RequestBody PasswordDTO request) {
        String mail = getCurrentUserMail();
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

    @PatchMapping("/me/password")
    public ResponseEntity<?> changePassword(@RequestBody PasswordDTO request) {
        String mail = getCurrentUserMail();
        accountService.changePassword(mail, request);

        return ResponseEntity.ok("Mật khẩu đã được cập nhật thành công");
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> deleteAccount(@PathVariable UUID uuid) {
        if (accountService.deleteAccount(uuid)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping
    public ResponseEntity<?> getAccounts(@RequestParam String role) {
        return ResponseEntity.ok(accountService.getAcountsRole(role));
    }
}
