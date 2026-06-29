package com.hospital.management.notification.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final EmailService emailService;

    // ============================================
    // 🏥 WELCOME EMAIL
    // ============================================
    @Override
    public void sendWelcomeEmail(String to, String patientName) {

        String subject = "Welcome to CareConnect Hospital 🏥";

        String body = baseTemplate("""
            <h2>🏥 Welcome to CareConnect</h2>

            <p>Dear <b>%s</b>,</p>

            <p>We are pleased to have you onboard.</p>

            <div class="box info">
                Your patient profile has been successfully created.
            </div>

            <p>You can now access:</p>
            <ul>
                <li>Doctor Consultations</li>
                <li>Lab Tests</li>
                <li>Pharmacy Services</li>
            </ul>

            <p>We wish you good health.</p>
        """.formatted(patientName));

        emailService.sendHtmlEmail(to, subject, body);
    }

    // ============================================
    // 📅 APPOINTMENT BOOKED
    // ============================================
    @Override
    public void sendAppointmentBookedEmail(String to, String patientName, String doctorName, String time) {

        String subject = "Appointment Confirmed";

        String body = baseTemplate("""
            <h2>📅 Appointment Confirmed</h2>

            <p>Dear <b>%s</b>,</p>

            <p>Your appointment has been successfully scheduled.</p>

            <div class="box info">
                <b>Doctor:</b> %s<br>
                <b>Date & Time:</b> %s
            </div>

            <p>Please arrive 10 minutes early.</p>
        """.formatted(patientName, doctorName, time));

        emailService.sendHtmlEmail(to, subject, body);
    }

    // ============================================
    // 🔄 RESCHEDULED
    // ============================================
    @Override
    public void sendAppointmentRescheduledEmail(String to, String patientName, String doctorName, String time) {

        String subject = "Appointment Rescheduled";

        String body = baseTemplate("""
            <h2>🔄 Appointment Rescheduled</h2>

            <p>Dear <b>%s</b>,</p>

            <p>Your appointment has been rescheduled.</p>

            <div class="box warning">
                <b>Doctor:</b> %s<br>
                <b>New Time:</b> %s
            </div>
        """.formatted(patientName, doctorName, time));

        emailService.sendHtmlEmail(to, subject, body);
    }

    // ============================================
    // ❌ CANCELLED
    // ============================================
    @Override
    public void sendAppointmentCancelledEmail(String to, String patientName, String doctorName, String time) {

        String subject = "Appointment Cancelled";

        String body = baseTemplate("""
            <h2>❌ Appointment Cancelled</h2>

            <p>Dear <b>%s</b>,</p>

            <p>Your appointment has been cancelled.</p>

            <div class="box danger">
                <b>Doctor:</b> %s<br>
                <b>Time:</b> %s
            </div>

            <p>Please reschedule if required.</p>
        """.formatted(patientName, doctorName, time));

        emailService.sendHtmlEmail(to, subject, body);
    }
    // ============================================
// 🏥 VISIT CHECK-IN EMAIL
// ============================================
    @Override
    public void sendVisitCheckInEmail(String to, String patientName, String doctorName, String time) {

        String subject = "Visit Check-In Confirmed";

        String body = baseTemplate("""
        <h2>🏥 Visit Check-In Successful</h2>

        <p>Dear <b>%s</b>,</p>

        <p>You have been successfully checked in for your visit.</p>

        <div class="box info">
            <b>Doctor:</b> %s<br>
            <b>Check-In Time:</b> %s
        </div>

        <p>Please proceed to the waiting area.</p>
    """.formatted(patientName, doctorName, time));

        emailService.sendHtmlEmail(to, subject, body);
    }

    // ============================================
    // 🧪 LAB INVOICE
    // ============================================
    @Override
    public void sendLabInvoiceEmail(String to, String patientName, String pdfPath) {

        String subject = "Lab Invoice";

        String body = baseTemplate("""
            <h2>🧪 Lab Invoice</h2>

            <p>Dear <b>%s</b>,</p>

            <p>Your lab test has been scheduled.</p>

            <div class="box warning">
                Status: UNPAID
            </div>

            <p>Invoice is attached.</p>
        """.formatted(patientName));

        emailService.sendEmailWithAttachment(to, subject, body, pdfPath);
    }

    // ============================================
    // 🔥 LAB REPORT
    // ============================================
    @Override
    public void sendLabReportEmail(String to, String patientName, String pdfPath) {

        String subject = "Lab Report Ready";

        String body = baseTemplate("""
            <h2>🧪 Lab Report Ready</h2>

            <p>Dear <b>%s</b>,</p>

            <p>Your lab results are now available.</p>

            <div class="box success">
                You can find your report attached.
            </div>

            <p>For any clarification, consult your doctor.</p>
        """.formatted(patientName));

        emailService.sendEmailWithAttachment(to, subject, body, pdfPath);
    }

    // ============================================
    // 💊 PHARMACY
    // ============================================
    @Override
    public void sendPharmacyInvoiceEmail(String to, String patientName, String pdfPath) {

        String subject = "Pharmacy Bill";

        String body = baseTemplate("""
            <h2>💊 Pharmacy Bill</h2>

            <p>Dear <b>%s</b>,</p>

            <p>Your medicines have been dispensed.</p>

            <div class="box success">
                Status: PAID
            </div>

            <p>Bill attached.</p>
        """.formatted(patientName));

        emailService.sendEmailWithAttachment(to, subject, body, pdfPath);
    }

    @Override
    public void sendPharmacyDispensedEmail(
            String to,
            String patientName,
            String medicineName,
            int quantity) {

        String subject = "Medicines Dispensed - CareConnect";

        String body = """
    <html>
    <body style="font-family: Arial; background:#f4f6f8; padding:20px;">
    <div style="max-width:600px; margin:auto; background:white; padding:25px; border-radius:10px;">

        <h2>💊 Pharmacy Update</h2>

        <p>Dear <b>%s</b>,</p>

        <p>Your prescribed medicine has been dispensed.</p>

        <div style="background:#d4edda; padding:15px; border-radius:8px;">
            <b>Medicine:</b> %s<br>
            <b>Quantity:</b> %d
        </div>

        <p>Please follow the prescription guidelines strictly.</p>

        <p>
        Regards,<br>
        <b>CareConnect Hospital</b><br>
        Pharmacy Department
        </p>

    </div>
    </body>
    </html>
    """.formatted(patientName, medicineName, quantity);

        emailService.sendHtmlEmail(to, subject, body);
    }

    // ============================================
    // 🧾 FINAL BILL
    // ============================================
    @Override
    public void sendFinalInvoiceEmail(String to, String patientName, String pdfPath) {

        String subject = "Final Invoice";

        String body = baseTemplate("""
            <h2>🧾 Final Invoice</h2>

            <p>Dear <b>%s</b>,</p>

            <p>Your billing has been completed.</p>

            <div class="box success">
                Status: PAID
            </div>

            <p>Thank you for choosing CareConnect.</p>
        """.formatted(patientName));

        emailService.sendEmailWithAttachment(to, subject, body, pdfPath);
    }

    // ============================================
    // 🏥 COMMON TEMPLATE (🔥 IMPORTANT)
    // ============================================
    private String baseTemplate(String content) {

        return """
        <html>
        <body style="font-family: Arial; background:#f4f6f8; padding:20px;">

        <div style="max-width:600px; margin:auto; background:white; padding:25px; border-radius:10px;">

            %s

            <hr>

            <p style="font-size:12px; color:gray;">
                CareConnect Hospital<br>
                📍 Mumbai | 📞 +91-XXXXXXXXXX
            </p>

        </div>

        <style>
            .box { padding:12px; border-radius:8px; margin:10px 0; }
            .info { background:#eef5ff; }
            .success { background:#d4edda; }
            .warning { background:#fff3cd; }
            .danger { background:#f8d7da; }
        </style>

        </body>
        </html>
        """.formatted(content);
    }

    // ============================================
// 💰 PAYMENT RECEIPT (🔥 NEW)
// ============================================
    @Override
    public void sendPaymentReceiptEmail(
            String to,
            String patientName,
            Double paidAmount,
            Double totalAmount,
            Double remainingAmount,
            String pdfPath) {

        String subject = "Payment Receipt - CareConnect";

        String body = baseTemplate("""
        <h2>💰 Payment Received</h2>

        <p>Dear <b>%s</b>,</p>

        <p>We have successfully received your payment.</p>

        <div class="box info">
            <b>Paid Amount:</b> ₹%.2f<br>
            <b>Total Bill:</b> ₹%.2f<br>
            <b>Remaining:</b> ₹%.2f
        </div>

        <p>Please find your updated invoice attached.</p>

        <p>Thank you for choosing CareConnect.</p>
    """.formatted(
                patientName,
                paidAmount,
                totalAmount,
                remainingAmount
        ));

        emailService.sendEmailWithAttachment(to, subject, body, pdfPath);
    }
    // ============================================
// 👨‍⚕️ DOCTOR AVAILABILITY (🔥 NEW)
// ============================================
    @Override
    public void sendDoctorAvailabilityEmail(
            String to,
            String doctorName,
            String schedule) {

        String subject = "Availability Updated - CareConnect";

        String body = baseTemplate("""
        <h2>📅 Availability Updated</h2>

        <p>Dear Dr. <b>%s</b>,</p>

        <p>Your availability schedule has been successfully updated.</p>

        <div class="box info">
            %s
        </div>

        <p>This schedule is now visible for patient bookings.</p>
    """.formatted(doctorName, schedule));

        emailService.sendHtmlEmail(to, subject, body);
    }
}