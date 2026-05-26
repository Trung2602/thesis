package com.lht.services.impl;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.lht.dto.AdminDTO;
import com.lht.dto.AdminRequestDTO;
import com.lht.pojo.AccountRole;
import com.lht.pojo.Admin;
import com.lht.pojo.GenderType;
import com.lht.repositories.AdminRepository;
import com.lht.services.AdminService;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@Transactional
@RequiredArgsConstructor
public class AdminServiceImpl implements AdminService {

    private final AdminRepository adminRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    @Autowired
    private Cloudinary cloudinary;

    private AdminDTO mapToDTO(Admin a) {
        if (a == null)
            return null;

        return  AdminDTO.builder()
                .uuid(a.getUuid())
                .mail(a.getMail())
                .name(a.getName())
                .avatar(a.getAvatar())
                .birthday(a.getBirthday())
                .gender(a.getGender().name())
                .isActive(a.getIsActive())
                .role(a.getRole().name())
                .build();
    }

    private List<AdminDTO> mapToDTO(List<Admin> admins) {
        if (admins == null || admins.isEmpty())
            return List.of();

        return admins.stream()
                .map(this::mapToDTO)
                .toList();
    }

    private Admin toEntity(AdminDTO dto) {
        if (dto == null)
            return null;

        Admin a = new Admin();

        a.setUuid(dto.getUuid());
        a.setMail(dto.getMail());
        a.setName(dto.getName());
        a.setBirthday(dto.getBirthday());
        a.setIsActive(dto.getIsActive());

        if (dto.getGender() != null) {
            a.setGender(GenderType.valueOf(dto.getGender()));
        }

        a.setRole(AccountRole.ADMIN);

        return a;
    }

    @Override
    public AdminDTO getAdminById(UUID uuid) {
        return adminRepository.findById(uuid)
                .map(this::mapToDTO).orElse(null);
    }

    @Override
    public AdminDTO createAdmin(AdminRequestDTO dto) {
        Admin admin = new Admin();
        admin.setMail(dto.getMail());
        admin.setName(dto.getName());
        admin.setBirthday(dto.getBirthday());
        admin.setGender(GenderType.valueOf(dto.getGender().toUpperCase()));
        admin.setIsActive(true);
        admin.setRole(AccountRole.ADMIN);
        admin.setCreatedAt(LocalDateTime.now());
        if (dto.getPermissions() != null) {
            admin.setPermissions("All");
        }
        admin.setPasswordHash(passwordEncoder.encode(dto.getPassword()));
        admin.setAvatar("https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg");

        Admin saved = adminRepository.save(admin);
        return mapToDTO(saved);
    }

    @Override
    public AdminDTO updateAdmin(AdminRequestDTO dto, MultipartFile file) {
        Admin admin = adminRepository.findById(dto.getUuid()).orElseThrow(() -> new RuntimeException("Admin không tồn tại"));
        admin.setMail(dto.getMail());
        admin.setName(dto.getName());
        admin.setBirthday(dto.getBirthday());
        if (dto.getGender() != null) {
            admin.setGender(GenderType.valueOf(dto.getGender()));
        }
        if (dto.getIsActive() != null) {
            admin.setIsActive(dto.getIsActive());
        }
        if (dto.getPassword() != null) {
            admin.setPasswordHash(passwordEncoder.encode(dto.getPassword()));
        }
        if (dto.getPermissions() != null) {
            admin.setPermissions(dto.getPermissions());
        }
        if (file != null && !file.isEmpty()) {
            try {
                Map res = cloudinary.uploader().upload(
                        file.getBytes(),
                        ObjectUtils.asMap("resource_type", "auto")
                );
                admin.setAvatar(res.get("secure_url").toString());

            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
        Admin saved = adminRepository.save(admin);
        return mapToDTO(saved);
    }
}
