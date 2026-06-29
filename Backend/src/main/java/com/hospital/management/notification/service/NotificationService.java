package com.hospital.management.notification.service;

public interface NotificationService {

    // ============================================
    // 🏥 PATIENT
    // ============================================

    void sendWelcomeEmail(String to, String patientName);

    // ============================================
    // 📅 APPOINTMENTS
    // ============================================

    void sendAppointmentBookedEmail(String to, String patientName, String doctorName, String time);

    void sendAppointmentRescheduledEmail(String to, String patientName, String doctorName, String time);

    void sendAppointmentCancelledEmail(String to, String patientName, String doctorName, String time);

    // ============================================
    // 🏥 VISIT
    // ============================================

    void sendVisitCheckInEmail(String to, String patientName, String doctorName, String time);

    // ============================================
    // 🧪 LAB
    // ============================================

    void sendLabInvoiceEmail(String to, String patientName, String pdfPath);

    void sendLabReportEmail(String to, String patientName, String pdfPath);

    // ============================================
    // 💊 PHARMACY
    // ============================================

    void sendPharmacyInvoiceEmail(String to, String patientName, String pdfPath);

    void sendPharmacyDispensedEmail(
            String to,
            String patientName,
            String medicineName,
            int quantity
    );

    // ============================================
    // 🧾 BILLING (🔥 IMPORTANT)
    // ============================================

    // FINAL BILL (on CLOSE)
    void sendFinalInvoiceEmail(String to, String patientName, String pdfPath);

    // 🔥 NEW → PAYMENT UPDATE EMAIL
    void sendPaymentReceiptEmail(
            String to,
            String patientName,
            Double paidAmount,
            Double totalAmount,
            Double remainingAmount,
            String pdfPath
    );

    // ============================================
    // 👨‍⚕️ DOCTOR
    // ============================================

    // 🔥 NEW → DOCTOR AVAILABILITY EMAIL
    void sendDoctorAvailabilityEmail(
            String to,
            String doctorName,
            String schedule
    );
}