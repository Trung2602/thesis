package com.lht.jwt;

import com.lht.pojo.UserPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.UUID;

public class SecurityUtils {

    public static UUID getCurrentUserUuid() {
        UserPrincipal user = (UserPrincipal) SecurityContextHolder
                .getContext()
                .getAuthentication()
                .getPrincipal();

        return user.getUuid();
    }

    public static String getCurrentUserMail() {
        UserPrincipal user = (UserPrincipal) SecurityContextHolder
                .getContext()
                .getAuthentication()
                .getPrincipal();

        return user.getMail();
    }

    public static String getCurrentUserRole() {
        var auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth == null || auth.getAuthorities().isEmpty()) {
            throw new RuntimeException("User chưa xác thực");
        }
        String role = auth.getAuthorities().iterator().next().getAuthority();
        return role.replace("ROLE_", "");
    }
}
