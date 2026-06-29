package com.hospital.management.notification.service;

public interface EmailService {

    void sendEmail(String to, String subject, String body);

    void sendHtmlEmail(String to, String subject, String body);

    void sendEmailWithAttachment(String to, String subject, String body, String filePath);

}