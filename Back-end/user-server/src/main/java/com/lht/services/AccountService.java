package com.lht.services;

import com.lht.dto.AccountDTO;
import com.lht.dto.InternalUserResponse;
import com.lht.dto.PasswordDTO;
import com.lht.pojo.Account;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.web.multipart.MultipartFile;

public interface AccountService extends UserDetailsService{

    List<AccountDTO> getAllAccounts();
    List<AccountDTO> getAccounts(Map<String, String> params);
    AccountDTO getAccountById(UUID uuid);
    Account getById(UUID uuid);
    AccountDTO updateProfile(String mail, AccountDTO dto, MultipartFile file);
    boolean deleteAccount(UUID uuid);
    boolean changeIsActive(UUID uuid);
    Account authenticate(String mail, String password);
    AccountDTO getCurrentAccountDTO(String mail);
    Account getAccountByMail(String mail);
    String checkDuplicate(String mail);
    void changePassword(String mail, PasswordDTO request);
    String getRoleByUuid(UUID uuid);
    boolean existsByUuid(UUID uuid);
    InternalUserResponse getInternalUserByMail(String mail);
    InternalUserResponse getInternalUserByUuid(UUID uuid);
}
