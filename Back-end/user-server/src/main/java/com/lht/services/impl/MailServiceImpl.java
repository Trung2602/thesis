package com.lht.services.impl;

import com.lht.pojo.Customer;
import com.lht.repositories.CustomerRepository;
import com.lht.services.MailService;
import java.text.SimpleDateFormat;
import java.util.Optional;

import lombok.RequiredArgsConstructor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
@RequiredArgsConstructor
public class MailServiceImpl implements MailService {

    private final JavaMailSender mailSender;
    private final CustomerRepository customerRepository;

    @Override
    public void sendPaymentSuccess(String mail, String payName) {
        Optional<Customer> optionalAcc = customerRepository.findByMail(mail);
        if (optionalAcc.isPresent()) {
            Customer customer = optionalAcc.get();
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
            String formattedDate = sdf.format(customer.getExpiryDate());

            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(mail);
            message.setSubject("Xác nhận thanh toán thành công");

            message.setText("Xin chào " + customer.getName() + ",\n\n"
                    + "Thanh toán của bạn đã được thực hiện thành công.\n"
                    + "Gói tập: " + payName + "\n"
                    + "Ngày hết hạn mới: " + formattedDate + "\n\n"
                    + "Cảm ơn bạn đã tin tưởng phòng gym của chúng tôi!");

            mailSender.send(message);
        } else {
            System.out.println("Không tìm thấy tài khoản với email: " + mail);
        }
    }

    @Override
    public void sendOTP(String mail, int otp) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(mail);
        message.setSubject("Mã xác thực OTP đăng ký thành viên");

        message.setText("Xin chào " + ",\n\n"
                + "Cảm ơn bạn đã đăng ký thành viên tại phòng gym của chúng tôi.\n"
                + "Mã OTP của bạn là: " + otp + "\n\n"
                + "Vui lòng nhập mã này để hoàn tất quá trình đăng ký.\n\n"
                + "Trân trọng!");

        mailSender.send(message);
    }

    @Override
    public void sendWelcomeMail(String mail) {
        Optional<Customer> optionalAcc = customerRepository.findByMail(mail);
        if (optionalAcc.isPresent()) {
            Customer customer = optionalAcc.get();
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(mail);
            message.setSubject("Chào mừng bạn đến với phòng gym!");

            message.setText("Xin chào " + customer.getName() + ",\n\n"
                    + "Chúc mừng bạn đã trở thành thành viên mới của phòng gym.\n"
                    + "Hãy cùng chúng tôi bắt đầu hành trình rèn luyện sức khoẻ và thể hình nhé!\n\n"
                    + "Cảm ơn bạn đã lựa chọn dịch vụ của chúng tôi.\n\n"
                    + "Trân trọng,\nĐội ngũ phòng gym");

            mailSender.send(message);
        } else {
            System.out.println("Không tìm thấy tài khoản với email: " + mail);
        }
    }

}
