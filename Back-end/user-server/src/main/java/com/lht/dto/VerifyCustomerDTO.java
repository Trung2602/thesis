package com.lht.dto;

import com.lht.pojo.Customer;
import lombok.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VerifyCustomerDTO {

    private CustomerRequestDTO dto;
    private MultipartFile file;
    private int otp;
    private LocalDateTime expiryTime;

    public VerifyCustomerDTO(CustomerRequestDTO dto, MultipartFile file, int otp) {
        this.dto = dto;
        this.file = file;
        this.otp = otp;
        this.expiryTime = LocalDateTime.now().plusMinutes(5);
    }

    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiryTime);
    }
}
