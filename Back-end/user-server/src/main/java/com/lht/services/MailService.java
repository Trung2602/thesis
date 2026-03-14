package com.lht.services;

public interface MailService {
    public void sendPaymentSuccess(String mail, String payName);

    public void sendOTP(String mail, int otp);

    public void sendWelcomeMail(String mail);
}
