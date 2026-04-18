package com.lht.configs;

import com.lht.component.JwtFilter;
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

import java.util.List;

@Configuration
@EnableWebSecurity
@EnableTransactionManagement
@ComponentScan(basePackages = {
        "com.lht.controllers",
        "com.lht.repository",
        "com.lht.service"
})
public class SecurityConfig {

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
        http.cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                .authorizeHttpRequests(auth -> auth

                        // ===== INTERNAL MICROSERVICE =====
                        .requestMatchers("/internal/**").permitAll()

                        // ===== FACILITY =====
                        .requestMatchers(HttpMethod.GET, "/api/v1/gym/facilities/**").permitAll()

                        // ===== PLANS =====
                        .requestMatchers(HttpMethod.GET, "/api/v1/gym/plans/**").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/v1/gym/plans").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/v1/gym/plans/**").hasRole("ADMIN")

                        // ===== CUSTOMER SCHEDULE =====
                        .requestMatchers(HttpMethod.GET, "/api/v1/gym/customer-schedules/**").hasAnyRole("CUSTOMER","STAFF","ADMIN")
                        .requestMatchers(HttpMethod.POST, "/api/v1/gym/customer-schedules").hasAnyRole("CUSTOMER","ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/v1/gym/customer-schedules/**").hasAnyRole("CUSTOMER","ADMIN")

                        // ===== PAY CUSTOMER =====
                        .requestMatchers(HttpMethod.GET, "/api/v1/gym/pay-customers/**").hasAnyRole("CUSTOMER","ADMIN")
                        .requestMatchers(HttpMethod.POST, "/api/v1/gym/pay-customers").hasAnyRole("CUSTOMER","ADMIN")

                        // ===== PAYMENT =====
                        .requestMatchers("/api/v1/gym/payment/**").hasAnyRole("CUSTOMER")

                        // ===== SALARY =====
                        .requestMatchers("/api/v1/gym/salaries/**").hasAnyRole("ADMIN","STAFF")

                        // ===== SHIFT =====
                        .requestMatchers("/api/v1/gym/shifts/**").hasAnyRole("ADMIN","STAFF")

                        // ===== STAFF DAY OFF =====
                        .requestMatchers("/api/v1/gym/day-offs/**").hasAnyRole("ADMIN","STAFF")

                        // ===== STAFF SCHEDULE =====
                        .requestMatchers("/api/v1/gym/staff-schedules/**").hasAnyRole("ADMIN","STAFF")

                        // ===== REPORT =====
                        .requestMatchers("/api/v1/gym/report/**").hasRole("ADMIN")

                        // ===== DEFAULT =====
                        .anyRequest().authenticated()
                )
                .formLogin(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable)
                .addFilterBefore(new JwtFilter(), UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();

        config.setAllowedOrigins(List.of("http://localhost:3000"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("Authorization", "Content-Type"));
        config.setExposedHeaders(List.of("Authorization"));
        config.setAllowCredentials(true); // Nếu dùng cookie

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);

        return source;
    }
}
