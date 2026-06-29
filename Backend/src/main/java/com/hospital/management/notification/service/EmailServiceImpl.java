package com.hospital.management.notification.service;

import jakarta.mail.internet.MimeMessage;
import org.springframework.core.io.FileSystemResource;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.io.File;

@Service
public class EmailServiceImpl implements EmailService {

    private final JavaMailSender mailSender;

    public EmailServiceImpl(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    // ✅ PLAIN TEXT EMAIL (fallback)
    @Override
    public void sendEmail(String to, String subject, String body) {

        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom("noreplay.careconnect@gmail.com");
        message.setTo(to);
        message.setSubject(subject);
        message.setText(body);

        mailSender.send(message);
    }

    // 🔥 HTML EMAIL (NO ATTACHMENT)
    @Override
    public void sendHtmlEmail(String to, String subject, String body) {

        try {
            MimeMessage message = mailSender.createMimeMessage();

            MimeMessageHelper helper = new MimeMessageHelper(message, true);

            helper.setFrom("noreplay.careconnect@gmail.com");
            helper.setTo(to);
            helper.setSubject(subject);

            // 🔥 THIS FIXES YOUR ISSUE
            helper.setText(body, true);

            mailSender.send(message);

        } catch (Exception e) {
            throw new RuntimeException("Failed to send HTML email", e);
        }
    }

    // 🔥 HTML EMAIL WITH ATTACHMENT
    @Override
    public void sendEmailWithAttachment(String to, String subject, String body, String filePath) {

        try {
            MimeMessage message = mailSender.createMimeMessage();

            MimeMessageHelper helper = new MimeMessageHelper(message, true);

            helper.setFrom("noreplay.careconnect@gmail.com");
            helper.setTo(to);
            helper.setSubject(subject);

            helper.setText(body, true); // ✅ HTML enabled

            FileSystemResource file = new FileSystemResource(new File(filePath));
            helper.addAttachment(file.getFilename(), file);

            mailSender.send(message);

        } catch (Exception e) {
            throw new RuntimeException("Failed to send email with attachment", e);
        }
    }
}