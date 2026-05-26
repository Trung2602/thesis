package com.lht.services.impl;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.lht.client.InternalGymClient;
import com.lht.component.JwtUtils;
import com.lht.dto.*;
import com.lht.pojo.*;
import com.lht.repositories.AccountRepository;
import com.lht.services.AccountService;
import com.lht.services.AdminService;
import com.lht.services.CustomerService;
import com.lht.services.StaffService;
import feign.FeignException;
import jakarta.persistence.criteria.Predicate;

import java.io.IOException;
import java.math.BigDecimal;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import static com.lht.component.SecurityUtils.getCurrentUserMail;

@Service
@Transactional
@RequiredArgsConstructor
public class AccountServiceImpl implements AccountService {

    private final AccountRepository accountRepository;
    private final CustomerService customerService;
    private final BCryptPasswordEncoder passwordEncoder;
    private final InternalGymClient internalGymClient;

    @Autowired
    private Cloudinary cloudinary;

    @Autowired
    private JwtUtils jwtUtils;

    private AccountDTO mapToDTO(Account acc) {
        if (acc == null)
            return null;

        return AccountDTO.builder()
                .uuid(acc.getUuid())
                .mail(acc.getMail())
                .name(acc.getName())
                .role(acc.getRole().name())
                .avatar(acc.getAvatar())
                .birthday(acc.getBirthday())
                .gender(acc.getGender().name())
                .isActive(acc.getIsActive())
                .build();
    }

    private List<AccountDTO> mapToDTO(List<Account> accounts) {
        if (accounts == null || accounts.isEmpty()) {
            return List.of();
        }

        return accounts.stream()
                .map(this::mapToDTO)
                .toList();
    }

    @Override
    public List<AccountLiteDTO> getAcountsRole(String role) {
        AccountRole accountRole = AccountRole.valueOf(role);
        List<Account> accounts = accountRepository.findByRole(accountRole);

        return accounts.stream()
                .map(acc -> AccountLiteDTO.builder()
                        .uuid(acc.getUuid())
                        .name(acc.getName())
                        .mail(acc.getMail())
                        .role(acc.getRole().name())
                        .build())
                .toList();
    }

    @Override
    public List<AccountDTO> getAccounts(Map<String, String> params) {
        Specification<Account> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (params.containsKey("username")) {
                predicates.add(cb.like(cb.lower(root.get("username")), "%" + params.get("username").toLowerCase() + "%"));
            }

            if (params.containsKey("name")) {
                predicates.add(cb.like(cb.lower(root.get("name")), "%" + params.get("name").toLowerCase() + "%"));
            }

            if (params.containsKey("mail")) {
                predicates.add(cb.like(cb.lower(root.get("mail")), "%" + params.get("mail").toLowerCase() + "%"));
            }

            if (params.containsKey("gender")) {
                predicates.add(cb.equal(root.get("gender"), Boolean.parseBoolean(params.get("gender"))));
            }

            if (params.containsKey("isActive")) {
                predicates.add(cb.equal(root.get("isActive"), Boolean.parseBoolean(params.get("isActive"))));
            }

            if (params.containsKey("birthday")) {
                try {
                    DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
                    Date date = df.parse(params.get("birthday"));
                    predicates.add(cb.equal(root.get("birthday"), date));
                } catch (ParseException e) {
                    e.printStackTrace();
                }
            }

            if (params.containsKey("isActive")) {
                predicates.add(cb.equal(root.get("isActive"), Boolean.parseBoolean(params.get("isActive"))));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
        List<Account> accounts = accountRepository.findAll(spec);
        return mapToDTO(accounts);
    }

    @Override
    public AccountDTO updateProfile(String mail, AccountDTO dto, MultipartFile file) {

        Account acc = accountRepository.findByMail(mail).orElseThrow(() -> new RuntimeException("Tài khoản không tồn tại"));

        if (dto.getName() != null)
            acc.setName(dto.getName());

        if (dto.getBirthday() != null)
            acc.setBirthday(dto.getBirthday());

        if (dto.getGender() != null)
            acc.setGender(GenderType.valueOf(dto.getGender()));

        // upload avatar
        if (file != null && !file.isEmpty()) {
            try {
                Map uploadResult = cloudinary.uploader().upload(
                        file.getBytes(),
                        ObjectUtils.asMap("resource_type", "auto")
                );
                acc.setAvatar(uploadResult.get("secure_url").toString());
            } catch (IOException e) {
                throw new RuntimeException("Upload avatar thất bại");
            }
        }

        Account saved = accountRepository.save(acc);

        return new AccountDTO(saved);
    }

    @Override
    public boolean deleteAccount(UUID uuid) {
        Account account = accountRepository.findById(uuid).orElseThrow(() -> new RuntimeException("Account not found"));
        try {
            internalGymClient.deleteRelatedData(uuid, account.getRole().toString());
        } catch (FeignException e) {
            throw new RuntimeException("Không thể xóa dữ liệu liên quan ở gym-server: " + e.getMessage());
        }
        accountRepository.deleteById(uuid);
        return true;
    }

    @Override
    public LoginResponseDTO login(LoginRequestDTO request) throws Exception {
        if (request.getMail() == null || request.getPassword() == null) {
            throw new IllegalArgumentException("Mail hoặc password không được để trống");
        }
        Account account = this.authenticate(request.getMail(), request.getPassword());
        if (account == null) {
            throw new RuntimeException("Sai thông tin đăng nhập");
        }

        account.setLastLoginAt(LocalDateTime.now());
        accountRepository.save(account);

        String token = jwtUtils.generateToken(account.getMail(), account.getRole().name(), account.getUuid());
        String firebaseToken = jwtUtils.generateFirebaseToken(account.getUuid());
        return LoginResponseDTO.builder()
                .uuid(account.getUuid())
                .mail(account.getMail())
                .role(account.getRole().name())
                .token(token)
                .firebaseToken(firebaseToken)
                .build();
    }

    public Account authenticate(String mail, String password) {
        Optional<Account> optional = accountRepository.findByMail(mail);
        if (optional.isEmpty()) {
            return null;
        }
        Account account = optional.get();
        if (passwordEncoder.matches(password, account.getPasswordHash())) {
            return account;
        }
        return null;
    }

    @Override
    public UserDetails loadUserByUsername(String mail) throws UsernameNotFoundException {

        Account acc = accountRepository.findByMail(mail)
                .orElseThrow(() -> new UsernameNotFoundException("Không tìm thấy tài khoản: " + mail));

        Set<GrantedAuthority> authorities = new HashSet<>();
        authorities.add(new SimpleGrantedAuthority("ROLE_" + acc.getRole().name()));

        boolean accountNonExpired = true;

        if (acc.getRole() == AccountRole.CUSTOMER) {
            Customer customer = customerService.getByUuid(acc.getUuid());

            if (customer.getExpiryDate() != null && customer.getExpiryDate().isBefore(java.time.LocalDate.now())) {
                accountNonExpired = false;
            }
        }

        return new org.springframework.security.core.userdetails.User(
                acc.getMail(), //username
                acc.getPasswordHash(), //password
                acc.getIsActive(), //enabled: có được kich hoạt chưa
                accountNonExpired, //expired: hết hạn chưa
                true,
                true,
                authorities
        );
    }

    @Override
    public AccountDTO getCurrentAccountDTO() {
        String mail = getCurrentUserMail();

        Account account = accountRepository.findByMail(mail).orElseThrow(() -> new RuntimeException("Account not found"));

        String mailJWT = getCurrentUserMail();
        System.out.println("MAIL = " + mailJWT);

        if (account instanceof Staff staff) {
            StaffDTO dto = new StaffDTO(account);
            dto.setType(staff.getType().name());
            dto.setBaseSalary(staff.getBaseSalary());
            dto.setFacilityUuid(staff.getFacilityUuid());
            dto.setFacilityName(internalGymClient.getFacilityNameByUuid(staff.getFacilityUuid()));
            return dto;
        }
        if (account instanceof Customer customer) {
            CustomerDTO dto = new CustomerDTO(account);
            dto.setWeight(customer.getWeight());
            dto.setHeight(customer.getHeight());
            dto.setExpiryDate(customer.getExpiryDate());
            return dto;
        }
        if (account instanceof Admin admin) {
            AdminDTO dto = new AdminDTO(account);
            dto.setPermissions(admin.getPermissions());
            return dto;
        }
        return new AccountDTO(account);
    }

    @Override
    public String checkDuplicate(String mail) {
        if (accountRepository.findByMail(mail).isPresent()) {
            return "Mail đã tồn tại!";
        }
        return "OK";
    }

    @Override
    public void changePassword(String mail, PasswordDTO request) {
        Account account = accountRepository.findByMail(mail).orElseThrow(() -> new RuntimeException("Tài khoản không tồn tại"));
        if (!passwordEncoder.matches(request.getPassword(), account.getPasswordHash())) {
            throw new RuntimeException("Mật khẩu cũ không đúng");
        }
        String hashedPassword = passwordEncoder.encode(request.getNewPassword());
        account.setPasswordHash(hashedPassword);
        accountRepository.save(account);
    }

    @Override
    public void resetPassword(String mail, String newPassword) {
        Account account = accountRepository.findByMail(mail).orElseThrow(() -> new RuntimeException("Tài khoản không tồn tại"));
        account.setPasswordHash(passwordEncoder.encode(newPassword));
        accountRepository.save(account);
    }

    @Override
    public Account getAccountByMail(String mail) {
        Optional<Account> user = this.accountRepository.findByMail(mail);
        return user.orElse(null);
    }

    @Override
    public String getRoleByUuid(UUID uuid) {
        return accountRepository.findById(uuid)
                .map(account -> account.getRole().name())
                .orElseThrow(() -> new RuntimeException("Account not found"));
    }

    @Override
    public boolean existsByUuid(UUID uuid) {
        return accountRepository.existsById(uuid);
    }

    @Override
    public InternalUserResponse getInternalUserByMail(String mail) {

        Account account = accountRepository.findByMail(mail)
                .orElseThrow(() -> new RuntimeException("Account not found"));

        UUID uuid = account.getUuid();
        String role = account.getRole().name();

        BigDecimal baseSalary = null;
        String staffType = null;
        LocalDate expiryDate = null;

        if (account instanceof Staff staff) {
            baseSalary = staff.getBaseSalary();
            staffType = staff.getType().name();
        }

        if (account instanceof Customer customer) {
            expiryDate = customer.getExpiryDate();
        }

        return new InternalUserResponse(uuid, role, baseSalary, staffType, expiryDate);
    }

    @Override
    public InternalUserResponse getInternalUserByUuid(UUID uuid) {

        Account account = accountRepository.findById(uuid)
                .orElseThrow(() -> new RuntimeException("Account not found"));

        String role = account.getRole().name();

        BigDecimal baseSalary = null;
        String staffType = null;
        LocalDate expiryDate = null;

        if (account instanceof Staff staff) {
            baseSalary = staff.getBaseSalary();
            staffType = staff.getType().name();
        }

        if (account instanceof Customer customer) {
            expiryDate = customer.getExpiryDate();
        }

        return new InternalUserResponse(uuid, role, baseSalary, staffType, expiryDate);
    }
}
