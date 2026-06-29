package com.hospital.management.notification.service;

import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import org.springframework.stereotype.Service;

import java.io.File;

@Service
public class NotificationPdfServiceImpl implements NotificationPdfService {

    private static final String BASE_PATH = "C:/hospital-pdfs/";

    @Override
    public String generateLabInvoice(String patientName, double amount) {
        return createPdf("Lab Invoice", patientName, amount);
    }

    @Override
    public String generatePharmacyBill(String patientName, double amount) {
        return createPdf("Pharmacy Bill", patientName, amount);
    }

    @Override
    public String generateFinalInvoice(String patientName, double amount) {
        return createPdf("Final Invoice", patientName, amount);
    }

    private String createPdf(String title, String patientName, double amount) {

        try {
            File dir = new File(BASE_PATH);
            if (!dir.exists()) dir.mkdirs();

            String filePath = BASE_PATH + title.replace(" ", "_") + "_" + System.currentTimeMillis() + ".pdf";

            PdfWriter writer = new PdfWriter(filePath);
            PdfDocument pdf = new PdfDocument(writer);
            Document document = new Document(pdf);

            document.add(new Paragraph("🏥 CareConnect Hospital"));
            document.add(new Paragraph(" "));
            document.add(new Paragraph(title));
            document.add(new Paragraph("----------------------------"));
            document.add(new Paragraph("Patient: " + patientName));
            document.add(new Paragraph("Amount: ₹" + amount));
            document.add(new Paragraph("Status: Generated"));
            document.add(new Paragraph(" "));
            document.add(new Paragraph("Thank you for choosing us!"));

            document.close();

            return filePath;

        } catch (Exception e) {
            throw new RuntimeException("PDF generation failed", e);
        }
    }
}