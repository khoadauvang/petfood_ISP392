package com.isp392.petfood.service;

import com.isp392.petfood.entity.SupportTicket;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.mail.MailSendException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;

import java.time.format.DateTimeFormatter;

// Gửi email trả lời yêu cầu hỗ trợ qua Gmail SMTP (JavaMailSender).
// Chưa khai báo spring.mail.username / password trong .env thì không gửi, báo lỗi để reply được lưu FAILED.
@Component
public class SupportMailer {

    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final ObjectProvider<JavaMailSender> mailSender;
    private final String from;

    public SupportMailer(ObjectProvider<JavaMailSender> mailSender,
                         @Value("${spring.mail.username:}") String from) {
        this.mailSender = mailSender;
        this.from = from;
    }

    // Ném MailException nếu gửi lỗi (sai mật khẩu ứng dụng, mất mạng, chưa cấu hình...)
    public void sendReply(SupportTicket ticket, String replyContent) throws MailException {
        JavaMailSender sender = mailSender.getIfAvailable();
        if (sender == null || from.isBlank()) {
            throw new MailSendException("Chưa cấu hình Gmail SMTP (spring.mail.username / spring.mail.password trong .env)");
        }
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(from);
        message.setTo(ticket.getContactEmail());
        // Mã yêu cầu nằm trong tiêu đề để khách và nhân viên tra lại (requirements 7.10)
        message.setSubject("[PetFood] Trả lời yêu cầu hỗ trợ " + ticket.getTicketCode());
        message.setText(body(ticket, replyContent));
        sender.send(message);
    }

    private static String body(SupportTicket ticket, String replyContent) {
        String name = ticket.getContactName() == null || ticket.getContactName().isBlank()
                ? "bạn" : ticket.getContactName();
        return "Chào " + name + ",\n\n"
                + replyContent + "\n\n"
                + "-----\n"
                + "Yêu cầu " + ticket.getTicketCode() + " bạn gửi lúc " + ticket.getCreatedAt().format(DATE_TIME) + ":\n"
                + ticket.getContent() + "\n\n"
                + "PetFood";
    }
}
