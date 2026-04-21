package com.lht.component;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Setter
@Getter
@Component
@ConfigurationProperties(prefix = "vnp")
public class PaymentConfig {

    // Getter & Setter
    private String vnp_TmnCode;
    private String vnp_HashSecret;
    private String vnp_Url;
    private String vnp_ReturnUrl;
}
