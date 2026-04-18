package com.lht.repositories;

import com.lht.pojo.Account;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import com.lht.pojo.AccountRole;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface AccountRepository extends JpaRepository<Account, UUID>, JpaSpecificationExecutor<Account>{

    List<Account> findByRole(AccountRole role);
    Optional<Account> findByMail(String mail);
}
