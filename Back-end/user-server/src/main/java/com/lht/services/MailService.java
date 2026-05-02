package com.lht.services;

public interface MailService {
    void sendPaymentSuccess(String mail, String payName);

    void sendOTP(String mail, int otp);

    void sendWelcomeMail(String mail);
}
