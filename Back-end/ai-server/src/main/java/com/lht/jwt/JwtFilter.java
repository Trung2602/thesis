package com.lht.jwt;

import com.lht.pojo.UserPrincipal;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@Component
public class JwtFilter implements Filter {

    @Autowired
    private JwtUtils jwtUtils;

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String header = httpRequest.getHeader("Authorization");

        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7);
            try {
                if (jwtUtils.validateToken(token)) {
                    String mail = jwtUtils.getMail(token);
                    String role = jwtUtils.getRole(token);
                    String uuidStr = jwtUtils.getUuid(token);
                    UUID uuid = UUID.fromString(uuidStr);
                    UserPrincipal userPrincipal = new UserPrincipal(uuid, mail);
                    UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(
                            userPrincipal, null, List.of(new SimpleGrantedAuthority("ROLE_" + role))
                    );
                    SecurityContextHolder.getContext().setAuthentication(auth);
                }
            } catch (Exception e) {
                System.out.println("JWT error: " + e.getMessage());
            }
        }
        chain.doFilter(request, response);
    }
}


