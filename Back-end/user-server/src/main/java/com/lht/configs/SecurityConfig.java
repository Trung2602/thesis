package com.lht.configs;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.lht.component.JwtFilter;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.multipart.support.StandardServletMultipartResolver;

@Configuration
@EnableWebSecurity
@EnableTransactionManagement
@ComponentScan(basePackages = {
    "com.lht.controllers",
    "com.lht.repository",
    "com.lht.service"
})
public class SecurityConfig {

    @Autowired
    private JwtFilter jwtFilter;

    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    @Order(0)
    public StandardServletMultipartResolver multipartResolver() {
        return new StandardServletMultipartResolver();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http.csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                .authorizeHttpRequests(requests -> requests
                        .requestMatchers("/actuator/**").permitAll()
                        .requestMatchers("/login", "/css/**", "/images/logo_transparent_white.png", "/js/**").permitAll()
                        // ===== INTERNAL MICROSERVICE =====
                        .requestMatchers("/internal/**").permitAll()
                        // ===== AUTH  =====
                        .requestMatchers(HttpMethod.POST, "/api/v1/user/auth/login").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/v1/user/auth/register").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/v1/user/auth/register/verify-otp").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/v1/user/auth/password/forgot").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/v1/user/auth/password/forgot/verify-otp").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/v1/user/auth/password/reset").permitAll()
                        // ===== ACCOUNT =====
                        .requestMatchers(HttpMethod.GET,   "/api/v1/user/accounts/me").authenticated()
                        .requestMatchers(HttpMethod.PATCH, "/api/v1/user/accounts/me").authenticated()
                        .requestMatchers(HttpMethod.POST,  "/api/v1/user/accounts/me/password/verify").authenticated()
                        .requestMatchers(HttpMethod.PATCH, "/api/v1/user/accounts/me/password").authenticated()
                        .requestMatchers(HttpMethod.DELETE, "/api/v1/user/accounts/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.GET,   "/api/v1/user/accounts").hasRole("ADMIN")
                        // ===== ADMIN =====
                        .requestMatchers(HttpMethod.GET,   "/api/v1/user/admins/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.POST,  "/api/v1/user/admins").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PATCH, "/api/v1/user/admins").hasRole("ADMIN")
                        // ===== STAFF =====
                        .requestMatchers(HttpMethod.GET,   "/api/v1/user/staffs").hasAnyRole("ADMIN", "CUSTOMER")
                        .requestMatchers(HttpMethod.GET,   "/api/v1/user/staffs/working").hasAnyRole("ADMIN", "CUSTOMER")
                        .requestMatchers(HttpMethod.GET,   "/api/v1/user/staffs/**").hasAnyRole("ADMIN", "STAFF")
                        .requestMatchers(HttpMethod.POST,  "/api/v1/user/staffs").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PATCH, "/api/v1/user/staffs").hasRole("ADMIN")
                        // ===== CUSTOMER =====
                        .requestMatchers(HttpMethod.GET,   "/api/v1/user/customers/**").hasAnyRole("ADMIN", "CUSTOMER")
                        .requestMatchers(HttpMethod.POST,  "/api/v1/user/customers").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PATCH, "/api/v1/user/customers").hasRole("ADMIN")

                        // ===== DEFAULT =====
                        .anyRequest().authenticated())
                .formLogin(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable)
                .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }


    @Value("${cloudinary.cloud-name}")
    private String cloudName;
    @Value("${cloudinary.api-key}")
    private String apiKey;
    @Value("${cloudinary.api-secret}")
    private String apiSecret;

    @Bean
    public Cloudinary cloudinary() {
        return new Cloudinary(ObjectUtils.asMap(
                "cloud_name", cloudName,
                "api_key", apiKey,
                "api_secret", apiSecret,
                "secure", true
        ));
    }
}
