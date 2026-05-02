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
                        // ===== CHAT HISTORY =====
                        .requestMatchers(HttpMethod.GET, "/api/v1/ai/chat/history").hasRole("CUSTOMER")
                        // ===== EXERCISE =====
                        .requestMatchers(HttpMethod.GET, "/api/v1/ai/exercises").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.GET, "/api/v1/ai/exercises/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.POST, "/api/v1/ai/exercises").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PATCH, "/api/v1/ai/exercises/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/v1/ai/exercises/**").hasRole("ADMIN")
                        // ===== FOOD =====
                        .requestMatchers(HttpMethod.GET, "/api/v1/ai/foods").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.GET, "/api/v1/ai/foods/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.POST, "/api/v1/ai/foods").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PATCH, "/api/v1/ai/foods/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/v1/ai/foods/**").hasRole("ADMIN")
                        // ===== EMBEDDING =====
                        .requestMatchers(HttpMethod.POST, "/api/v1/ai/embedding/**").hasRole("ADMIN")
                        // ===== WEBSOCKET =====
                        .requestMatchers("/api/v1/ai/ai.ask/**").hasRole("CUSTOMER")
                        // ===== DEFAULT =====
                        .anyRequest().authenticated()
                )
                .formLogin(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable)
                .addFilterBefore(new JwtFilter(), UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
}
