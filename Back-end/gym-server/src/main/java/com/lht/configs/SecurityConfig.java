package com.lht.configs;

import com.lht.component.JwtFilter;
import org.springframework.beans.factory.annotation.Autowired;
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
        http.csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/actuator/**").permitAll()
                        // ===== INTERNAL MICROSERVICE =====
                        .requestMatchers("/internal/**").permitAll()

                        // ===== FACILITY =====
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/facilities").permitAll()
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/facilities/filter").permitAll()
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/facilities/sort").permitAll()
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/facilities/**").permitAll()
                        .requestMatchers(HttpMethod.POST,   "/api/v1/gym/facilities").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/v1/gym/facilities/**").hasRole("ADMIN")

                        // ===== PLANS =====
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/plans").permitAll()
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/plans/filter").permitAll()
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/plans/sort").permitAll()
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/plans/**").permitAll()
                        .requestMatchers(HttpMethod.POST,   "/api/v1/gym/plans").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/v1/gym/plans/**").hasRole("ADMIN")

                        // ===== CUSTOMER SCHEDULE =====
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/customer-schedules").hasAnyRole("CUSTOMER", "STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/customer-schedules/filter").hasAnyRole("CUSTOMER", "STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/customer-schedules/**").hasAnyRole("CUSTOMER", "STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.POST,   "/api/v1/gym/customer-schedules").hasAnyRole("CUSTOMER", "ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/v1/gym/customer-schedules/**").hasAnyRole("CUSTOMER", "ADMIN")

                        // ===== PAY CUSTOMER =====
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/pay-customers").hasAnyRole("CUSTOMER", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/pay-customers/filter").hasAnyRole("CUSTOMER", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/pay-customers/sort").hasAnyRole("CUSTOMER", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/pay-customers/**").hasAnyRole("CUSTOMER", "ADMIN")
                        .requestMatchers(HttpMethod.POST,   "/api/v1/gym/pay-customers").hasAnyRole("CUSTOMER", "ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/v1/gym/pay-customers/**").hasRole("ADMIN")

                        // ===== PAYMENT =====
                        .requestMatchers(HttpMethod.POST,   "/api/v1/gym/payment/create").hasRole("CUSTOMER")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/payment/return").permitAll()

                        // ===== SALARY =====
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/salaries").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/salaries/filter").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/salaries/month").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/salaries/**").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.POST,   "/api/v1/gym/salaries").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.POST,   "/api/v1/gym/salaries/calculate-month").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/v1/gym/salaries/**").hasRole("ADMIN")

                        // ===== SHIFT =====
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/shifts").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/shifts/filter").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/shifts/sort").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/shifts/**").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.POST,   "/api/v1/gym/shifts").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/v1/gym/shifts/**").hasRole("ADMIN")

                        // ===== STAFF DAY OFF =====
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/day-offs").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/day-offs/filter").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/day-offs/**").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.POST,   "/api/v1/gym/day-offs").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/v1/gym/day-offs/**").hasRole("ADMIN")

                        // ===== STAFF SCHEDULE =====
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/staff-schedules").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/staff-schedules/staff").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/staff-schedules/filter").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/staff-schedules/filter/staff").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/staff-schedules/page").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/staff-schedules/**").hasAnyRole("STAFF", "ADMIN")
                        .requestMatchers(HttpMethod.POST,   "/api/v1/gym/staff-schedules").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/v1/gym/staff-schedules/**").hasRole("ADMIN")

                        // ===== REPORT =====
                        .requestMatchers(HttpMethod.GET,    "/api/v1/gym/report").hasRole("ADMIN")

                        // ===== DEFAULT =====
                        .anyRequest().authenticated())
                .formLogin(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable)
                .addFilterBefore(new JwtFilter(), UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
}
