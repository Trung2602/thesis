package com.lht.repositories;

import com.lht.pojo.Staff;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import com.lht.pojo.StaffType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface StaffRepository extends JpaRepository<Staff, UUID>, JpaSpecificationExecutor<Staff>{

    List<Staff> findByType(StaffType type);
}
