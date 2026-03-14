package com.lht.services.impl;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.lht.client.InternalGymClient;
import com.lht.dto.InternalUserResponse;
import com.lht.dto.NameUUIDDTO;
import com.lht.dto.StaffDTO;
import com.lht.dto.StaffRequestDTO;
import com.lht.pojo.AccountRole;
import com.lht.pojo.GenderType;
import com.lht.pojo.Staff;
import com.lht.pojo.StaffType;
import com.lht.repositories.StaffRepository;
import com.lht.services.StaffService;
import jakarta.persistence.criteria.Predicate;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.*;
import java.util.stream.Collectors;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@Transactional
@RequiredArgsConstructor
public class StaffServiceImpl implements StaffService {

    private final StaffRepository staffRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final InternalGymClient internalGymClient;

    @Autowired
    private Cloudinary cloudinary;

    private StaffDTO mapToDTO(Staff s) {
        StaffDTO dto = new StaffDTO();

        dto.setUuid(s.getUuid());
        dto.setMail(s.getMail());
        dto.setName(s.getName());
        dto.setRole(s.getRole() != null ? s.getRole().name() : null);
        dto.setAvatar(s.getAvatar());
        dto.setBirthday(s.getBirthday());
        dto.setGender(s.getGender() != null ? s.getGender().name() : null);
        dto.setIsActive(s.getIsActive());

        dto.setType(s.getType() != null ? s.getType().name() : null);
        dto.setBaseSalary(s.getBaseSalary());
        dto.setFacilityUuid(s.getFacilityUuid());

        dto.setFacilityName(internalGymClient.getFacilityNameByUuid(s.getFacilityUuid()));
        return dto;
    }

    private List<StaffDTO> mapToDTO(List<Staff> staffs) {
        if (staffs.isEmpty()) {
            return List.of();
        }

        Set<UUID> facilityUuids = staffs.stream()
                .map(Staff::getFacilityUuid)
                .collect(Collectors.toSet());
        Map<UUID, String> facilityMap = internalGymClient.getFacilityNamesByUuids(facilityUuids);

        return staffs.stream()
                .map(s -> StaffDTO.builder()
                        .uuid(s.getUuid())
                        .mail(s.getMail())
                        .name(s.getName())
                        .role(s.getRole() != null ? s.getRole().name() : null)
                        .avatar(s.getAvatar())
                        .birthday(s.getBirthday())
                        .gender(s.getGender() != null ? s.getGender().name() : null)
                        .isActive(s.getIsActive())
                        .type(s.getType() != null ? s.getType().name() : null)
                        .baseSalary(s.getBaseSalary())
                        .facilityUuid(s.getFacilityUuid())
                        .facilityName(
                                facilityMap.getOrDefault(s.getFacilityUuid(), "Unknown")
                        )
                        .build())
                .collect(Collectors.toList());
    }

    private Staff toEntity(StaffDTO dto) {
        Staff s = new Staff();

        s.setUuid(dto.getUuid());
        s.setMail(dto.getMail());
        s.setName(dto.getName());

        if (dto.getRole() != null) {
            s.setRole(AccountRole.valueOf(dto.getRole()));
        }

        s.setAvatar(dto.getAvatar());
        s.setBirthday(dto.getBirthday());

        if (dto.getGender() != null) {
            s.setGender(GenderType.valueOf(dto.getGender()));
        }

        s.setIsActive(dto.getIsActive());

        s.setType(StaffType.valueOf(dto.getType().toUpperCase()));
        s.setBaseSalary(dto.getBaseSalary());
        s.setFacilityUuid(dto.getFacilityUuid());

        return s;
    }

    @Override
    public List<StaffDTO> getAllStaffs() {
        return mapToDTO(staffRepository.findAll());
    }

    @Override
    public StaffDTO getStaffByUuid(UUID uuid) {
        return staffRepository.findById(uuid).map(this::mapToDTO).orElse(null);
    }

    @Override
    public Staff getByUuid(UUID uuid) {
        return staffRepository.findById(uuid).orElse(null);
    }

    @Override
    public List<StaffDTO> getStaffs(Map<String, String> params) {

        Specification<Staff> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (params.containsKey("facilityUuid")) {
                predicates.add(cb.equal(
                        root.get("facilityUuid"),
                        UUID.fromString(params.get("facilityUuid"))
                ));
            }

            if (params.containsKey("type")) {
                predicates.add(cb.equal(
                        root.get("type"),
                        params.get("type")
                ));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };

        return mapToDTO(staffRepository.findAll(spec));
    }

    @Override
    public StaffDTO createStaff(StaffRequestDTO dto, MultipartFile file) {

        Staff staff = new Staff();
        staff.setMail(dto.getMail());
        staff.setName(dto.getName());
        staff.setBirthday(dto.getBirthday());
        staff.setGender(GenderType.valueOf(dto.getGender()));

        staff.setIsActive(true);
        staff.setRole(AccountRole.STAFF);

        staff.setType(StaffType.valueOf(dto.getType().toUpperCase()));
        staff.setBaseSalary(dto.getBaseSalary());
        staff.setFacilityUuid(dto.getFacilityUuid());

        // encode password
        staff.setPasswordHash(passwordEncoder.encode(dto.getPassword()));

        // upload avatar
        if (file != null && !file.isEmpty()) {
            try {
                Map res = cloudinary.uploader().upload(
                        file.getBytes(),
                        ObjectUtils.asMap("resource_type", "auto"));

                staff.setAvatar(res.get("secure_url").toString());

            } catch (IOException ex) {
                ex.printStackTrace();
            }
        } else {
            staff.setAvatar("https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg");
        }

        Staff saved = staffRepository.save(staff);

        return mapToDTO(saved);
    }

    @Override
    public StaffDTO updateStaff(StaffDTO dto, MultipartFile file) {

        Staff staff = staffRepository.findById(dto.getUuid()).orElseThrow(() -> new RuntimeException("Staff không tồn tại"));

        staff.setMail(dto.getMail());
        staff.setName(dto.getName());
        staff.setBirthday(dto.getBirthday());

        if (dto.getGender() != null) {
            staff.setGender(GenderType.valueOf(dto.getGender()));
        }

        if (dto.getIsActive() != null) {
            staff.setIsActive(dto.getIsActive());
        }

        staff.setType(StaffType.valueOf(dto.getType().toUpperCase()));
        staff.setBaseSalary(dto.getBaseSalary());
        staff.setFacilityUuid(dto.getFacilityUuid());

        // update avatar
        if (file != null && !file.isEmpty()) {
            try {
                Map res = cloudinary.uploader().upload(
                        file.getBytes(),
                        ObjectUtils.asMap("resource_type", "auto"));

                staff.setAvatar(res.get("secure_url").toString());

            } catch (IOException ex) {
                ex.printStackTrace();
            }
        } else {
            staff.setAvatar(dto.getAvatar());
        }

        Staff saved = staffRepository.save(staff);

        return mapToDTO(saved);
    }

    @Override
    public boolean deleteStaff(UUID uuid) {
        if (staffRepository.existsById(uuid)) {
            staffRepository.deleteById(uuid);
            return true;
        }
        return false;
    }

    @Override
    public List<InternalUserResponse> getStaffsAll() {

        return staffRepository.findAll().stream()
                .map(staff -> new InternalUserResponse(
                        staff.getUuid(),
                        "STAFF",
                        staff.getBaseSalary(),
                        staff.getType().name(),
                        null
                ))
                .toList();
    }

    @Override
    public String getStaffNameByUuid(UUID uuid) {

        return staffRepository.findById(uuid).map(Staff::getName).orElse("Unknown");
    }

    @Override
    public Map<UUID, String> getStaffNamesByUuids(Set<UUID> staffUuids) {

        List<Staff> staffs = staffRepository.findAllById(staffUuids);
        return staffs.stream().collect(Collectors.toMap(
                    Staff::getUuid,
                    Staff::getName
            ));
    }

    // Lấy staff type (FULLTIME / PARTTIME / INTERN)
    @Override
    public String getStaffType(UUID uuid) {

        return staffRepository.findById(uuid)
                .map(s -> s.getType().name())
                .orElseThrow(() -> new RuntimeException("Staff not found"));
    }

    @Override
    public List<UUID> getStaffsFulltime() {

        return staffRepository.findByType(StaffType.FULLTIME)
                .stream().map(Staff::getUuid).toList();
    }

    @Override
    public List<NameUUIDDTO> getAvailableStaff(LocalDate date, LocalTime checkin, LocalTime checkout) {

        Set<UUID> staffUuids = internalGymClient.getAvailableStaff(date, checkin, checkout);
        return staffRepository.findAllById(staffUuids)
                .stream()
                .map(s -> new NameUUIDDTO(s.getUuid(), s.getName()))
                .toList();
    }
}
