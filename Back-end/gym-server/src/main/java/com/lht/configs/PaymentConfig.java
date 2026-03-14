package com.lht.configs;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "vnp")
public class PaymentConfig {

    private String vnp_TmnCode;
    private String vnp_HashSecret;
    private String vnp_Url;
    private String vnp_ReturnUrl;

    // Getter & Setter
    public String getVnp_TmnCode() { return vnp_TmnCode; }
    public void setVnp_TmnCode(String vnp_TmnCode) { this.vnp_TmnCode = vnp_TmnCode; }

    public String getVnp_HashSecret() { return vnp_HashSecret; }
    public void setVnp_HashSecret(String vnp_HashSecret) { this.vnp_HashSecret = vnp_HashSecret; }

    public String getVnp_Url() { return vnp_Url; }
    public void setVnp_Url(String vnp_Url) { this.vnp_Url = vnp_Url; }

    public String getVnp_ReturnUrl() { return vnp_ReturnUrl; }
    public void setVnp_ReturnUrl(String vnp_ReturnUrl) { this.vnp_ReturnUrl = vnp_ReturnUrl; }
}
