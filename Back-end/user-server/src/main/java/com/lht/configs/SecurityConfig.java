package com.lht.configs;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.lht.jwt.JwtFilter;
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
        http.cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .csrf(csrf -> csrf.disable())
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                .authorizeHttpRequests(requests -> requests
                        // Cho phép truy cập các tài nguyên tĩnh
                        .requestMatchers("/login", "/css/**", "/images/logo_transparent_white.png", "/js/**").permitAll()
                        .requestMatchers("/").hasRole("ADMIN")
                        // ===== PUBLIC API =====
                        .requestMatchers("/api/v1/account/login").permitAll()
                        .requestMatchers("/api/v1/customer/register").permitAll()
                        .requestMatchers("/api/v1/customer/verify-otp").permitAll()

                        // ===== INTERNAL MICROSERVICE =====
                        .requestMatchers("/internal/**").permitAll()

                        // ===== STAFF =====
                        .requestMatchers(HttpMethod.GET, "/api/v1/staffs/available")
                        .hasAnyRole("ADMIN","CUSTOMER")

                        // ===== ACCOUNT =====
                        .requestMatchers("/api/v1/account/me").authenticated()
                        .requestMatchers("/api/v1/account/update").authenticated()
                        .requestMatchers("/api/v1/account/change-password").authenticated()
                        .requestMatchers("/api/v1/account/verify-password").authenticated()

                        // ===== DEFAULT =====
                        .anyRequest().authenticated())
                // Cấu hình form đăng nhập
//                .formLogin(form -> form.loginPage("/login")
//                .loginProcessingUrl("/login")
//                .successHandler((request, response, authentication) -> {
//                    // Nếu là ADMIN thì cho vào trang chủ
//                    if (authentication.getAuthorities().stream()
//                            .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"))) {
//                        response.sendRedirect("/");
//                    } else {
//                        // Nếu không phải ADMIN thì logout và trả về lỗi "forbidden"
//                        request.getSession().invalidate();
//                        response.sendRedirect("/login?error=forbidden");
//                    }
//                })
//                .failureHandler((request, response, exception) -> {
//                    // Sai username/password
//                    response.sendRedirect("/login?error=bad_credentials");
//                })
//                .permitAll()
//                )
                .formLogin(form -> form.disable())
                .httpBasic(httpBasic -> httpBasic.disable())
                .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
                //.logout(logout -> logout.logoutSuccessUrl("/login?logout=true").permitAll());
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

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();

        config.setAllowedOrigins(List.of("http://localhost:3000")); // frontend origin: cho phép port truy cập api
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("Authorization", "Content-Type"));
        config.setExposedHeaders(List.of("Authorization"));
        config.setAllowCredentials(true); // Nếu dùng cookie

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);

        return source;
    }
}
