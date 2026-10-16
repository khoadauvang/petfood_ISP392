package com.isp392.petfood.service;

import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.mail.MailSendException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;

// Gửi mã OTP quên mật khẩu qua Gmail SMTP (cùng cấu hình spring.mail.* với SupportMailer)
@Component
public class PasswordResetMailer {

    private final ObjectProvider<JavaMailSender> mailSender;
    private final String from;

    public PasswordResetMailer(ObjectProvider<JavaMailSender> mailSender,
                               @Value("${spring.mail.username:}") String from) {
        this.mailSender = mailSender;
        this.from = from;
    }

    // Ném MailException nếu gửi lỗi (chưa cấu hình, sai mật khẩu ứng dụng, mất mạng...)
    public void sendOtp(String to, String otp, int validMinutes) throws MailException {
        JavaMailSender sender = mailSender.getIfAvailable();
        if (sender == null || from.isBlank()) {
            throw new MailSendException("Chưa cấu hình Gmail SMTP (spring.mail.username / spring.mail.password trong .env)");
        }
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(from);
        message.setTo(to);
        message.setSubject("[Food Pet Shop] Mã OTP đặt lại mật khẩu");
        message.setText("Chào bạn,\n\n"
                + "Mã OTP đặt lại mật khẩu của bạn là: " + otp + "\n\n"
                + "Mã có hiệu lực trong " + validMinutes + " phút và chỉ dùng được một lần. "
                + "Không chia sẻ mã này cho bất kỳ ai, kể cả nhân viên cửa hàng.\n\n"
                + "Nếu bạn không yêu cầu đặt lại mật khẩu, hãy bỏ qua email này; mật khẩu hiện tại vẫn giữ nguyên.\n\n"
                + "Food Pet Shop");
        sender.send(message);
    }
}
