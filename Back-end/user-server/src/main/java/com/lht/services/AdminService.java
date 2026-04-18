package com.lht.services;

import com.lht.dto.AdminDTO;
import com.lht.dto.AdminRequestDTO;
import com.lht.pojo.Admin;
import java.util.List;
import java.util.UUID;

import org.springframework.web.multipart.MultipartFile;

public interface AdminService {

    AdminDTO getAdminById(UUID uuid);
    AdminDTO createAdmin(AdminRequestDTO dto, MultipartFile file);
    AdminDTO updateAdmin(AdminDTO dto, MultipartFile file);
}
