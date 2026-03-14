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

        return (AdminDTO) AdminDTO.builder()
                .uuid(a.getUuid())
                .mail(a.getMail())
                .name(a.getName())
                .avatar(a.getAvatar())
                .birthday(a.getBirthday())
                .gender(a.getGender().name())
                .isActive(a.getIsActive())
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
    public List<AdminDTO> getAllAdmins() {
        return mapToDTO(adminRepository.findAll());
    }

    @Override
    public AdminDTO getAdminById(UUID uuid) {
        return adminRepository.findById(uuid)
                .map(this::mapToDTO).orElse(null);
    }

    @Override
    public Admin getById(UUID uuid) {
        return adminRepository.findById(uuid).orElse(null);
    }

    @Override
    public AdminDTO createAdmin(AdminRequestDTO dto, MultipartFile file) {

        Admin admin = new Admin();
        admin.setMail(dto.getMail());
        admin.setName(dto.getName());
        admin.setBirthday(dto.getBirthday());
        admin.setGender(GenderType.valueOf(dto.getGender()));

        admin.setIsActive(true);
        admin.setRole(AccountRole.ADMIN);

        // encode password
        admin.setPasswordHash(passwordEncoder.encode(dto.getPassword()));

        // upload avatar
        if (file != null && !file.isEmpty()) {
            try {
                Map res = cloudinary.uploader().upload(
                        file.getBytes(),
                        ObjectUtils.asMap("resource_type", "auto"));

                admin.setAvatar(res.get("secure_url").toString());

            } catch (IOException ex) {
                ex.printStackTrace();
            }
        } else {
            admin.setAvatar("https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg");
        }

        Admin saved = adminRepository.save(admin);

        return mapToDTO(saved);
    }

    @Override
    public AdminDTO updateAdmin(AdminDTO dto, MultipartFile file) {

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

        // update avatar
        if (file != null && !file.isEmpty()) {
            try {
                Map res = cloudinary.uploader().upload(
                        file.getBytes(),
                        ObjectUtils.asMap("resource_type", "auto"));

                admin.setAvatar(res.get("secure_url").toString());

            } catch (IOException ex) {
                ex.printStackTrace();
            }
        } else {
            admin.setAvatar(dto.getAvatar());
        }

        Admin saved = adminRepository.save(admin);

        return mapToDTO(saved);
    }

    @Override
    public boolean deleteAdmin(UUID uuid) {
        if (adminRepository.existsById(uuid)) {
            adminRepository.deleteById(uuid);
            return true;
        }
        return false;
    }
}
