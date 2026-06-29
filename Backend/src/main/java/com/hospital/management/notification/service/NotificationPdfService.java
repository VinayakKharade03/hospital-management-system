package com.hospital.management.notification.service;

public interface NotificationPdfService {

    String generateLabInvoice(String patientName, double amount);

    String generatePharmacyBill(String patientName, double amount);

    String generateFinalInvoice(String patientName, double amount);
}