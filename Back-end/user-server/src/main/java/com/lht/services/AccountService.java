package com.lht.services;

import com.lht.dto.*;
import com.lht.pojo.Account;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.web.multipart.MultipartFile;

public interface AccountService extends UserDetailsService{

    List<AccountLiteDTO> getAcountsRole(String role);
    List<AccountDTO> getAccounts(Map<String, String> params);
    AccountDTO updateProfile(String mail, AccountDTO dto, MultipartFile file);
    boolean deleteAccount(UUID uuid);
    LoginResponseDTO login(LoginRequestDTO request) throws Exception;
    AccountDTO getCurrentAccountDTO();
    Account getAccountByMail(String mail);
    String checkDuplicate(String mail);
    void changePassword(String mail, PasswordDTO request);
    String getRoleByUuid(UUID uuid);
    boolean existsByUuid(UUID uuid);
    InternalUserResponse getInternalUserByMail(String mail);
    InternalUserResponse getInternalUserByUuid(UUID uuid);
}
