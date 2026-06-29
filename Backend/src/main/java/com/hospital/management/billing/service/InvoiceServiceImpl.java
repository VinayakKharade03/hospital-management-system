package com.hospital.management.billing.service;

import com.hospital.management.billing.entity.Invoice;
import com.hospital.management.billing.entity.InvoiceItem;
import com.hospital.management.billing.enums.InvoiceStatus;
import com.hospital.management.billing.enums.PaymentStatus;
import com.hospital.management.billing.repository.InvoiceItemRepository;
import com.hospital.management.billing.repository.InvoiceRepository;

import com.hospital.management.patient.entity.Patient;
import com.hospital.management.patient.repository.PatientRepository;

import com.hospital.management.visit.entity.Visit;
import com.hospital.management.visit.repository.VisitRepository;

import com.hospital.management.notification.service.NotificationService;
import com.hospital.management.notification.service.EmailService;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class InvoiceServiceImpl implements InvoiceService {

    private final InvoiceRepository invoiceRepository;
    private final InvoiceItemRepository itemRepository;
    private final PatientRepository patientRepository;
    private final VisitRepository visitRepository;

    private final BillingPdfService billingPdfService;
    private final NotificationService notificationService;
    private final EmailService emailService;

    public InvoiceServiceImpl(
            InvoiceRepository invoiceRepository,
            InvoiceItemRepository itemRepository,
            PatientRepository patientRepository,
            VisitRepository visitRepository,
            BillingPdfService billingPdfService,
            NotificationService notificationService,
            EmailService emailService) {

        this.invoiceRepository = invoiceRepository;
        this.itemRepository = itemRepository;
        this.patientRepository = patientRepository;
        this.visitRepository = visitRepository;
        this.billingPdfService = billingPdfService;
        this.notificationService = notificationService;
        this.emailService = emailService;
    }

    // ================================
    // CREATE INVOICE
    // ================================
    @Override
    @Transactional
    public Invoice createInvoice(Long patientId) {

        Patient patient = patientRepository.findById(patientId)
                .orElseThrow(() -> new RuntimeException("Patient not found"));

        Invoice invoice = new Invoice();
        invoice.setPatient(patient);
        invoice.setStatus(InvoiceStatus.OPEN);
        invoice.setPaymentStatus(PaymentStatus.PENDING);
        invoice.setPaidAmount(0.0);
        invoice.setTotalAmount(0.0);

        Invoice saved = invoiceRepository.save(invoice);

        // 🔥 EMAIL ON CREATE
        sendInvoiceCreatedEmail(saved);

        return saved;
    }

    // ================================
    // VISIT BASED
    // ================================
    @Override
    @Transactional
    public Invoice getOrCreateByVisit(Long visitId) {

        return invoiceRepository.findByVisitIdWithItems(visitId)
                .orElseGet(() -> {

                    Visit visit = visitRepository.findById(visitId)
                            .orElseThrow(() -> new RuntimeException("Visit not found"));

                    Invoice inv = new Invoice();
                    inv.setVisit(visit);
                    inv.setPatient(visit.getPatient());
                    inv.setStatus(InvoiceStatus.OPEN);
                    inv.setPaymentStatus(PaymentStatus.PENDING);
                    inv.setPaidAmount(0.0);
                    inv.setTotalAmount(0.0);

                    // Save parent invoice first to generate an ID
                    Invoice savedInvoice = invoiceRepository.save(inv);
                    Long newInvoiceId = savedInvoice.getId();

                    // Add doctor consultation fee as a line item.
                    //
                    // GUARD: only insert if no "Consultation" item already exists on
                    // this invoice. This prevents a duplicate when another service
                    // (e.g. VisitService) has already added the fee under a different
                    // naming format such as "Doctor Consultation - <fullName>".
                    if (visit.getDoctor() != null
                            && visit.getDoctor().getConsultationFee() != null
                            && visit.getDoctor().getConsultationFee() > 0.0) {

                        boolean alreadyAdded = itemRepository
                                .existsByInvoiceIdAndItemNameContainingIgnoreCase(
                                        newInvoiceId, "Consultation");

                        if (!alreadyAdded) {
                            double doctorFee = visit.getDoctor().getConsultationFee();
                            String itemName = "Doctor Consultation Fee — Dr. "
                                    + visit.getDoctor().getLastName();

                            // addServiceItem persists the item AND updates totalAmount in DB.
                            // savedInvoice is intentionally not touched after this point —
                            // its in-memory totalAmount is stale and must not be saved again.
                            addServiceItem(newInvoiceId, itemName, 1, doctorFee);
                        }
                    }

                    // Re-fetch so we return a DB-accurate entity with correct totalAmount
                    // and a fully-initialized items collection.
                    Invoice freshInvoice = invoiceRepository.findByVisitIdWithItems(visitId)
                            .orElseThrow(() -> new RuntimeException(
                                    "Invoice vanished after save: " + newInvoiceId));

                    // 🔥 EMAIL ON AUTO CREATE
                    sendInvoiceCreatedEmail(freshInvoice);

                    return freshInvoice;
                });
    }

    // ================================
    // GET OR CREATE (PATIENT)
    // ================================
    @Override
    @Transactional
    public Invoice getOrCreateOpenInvoice(Long patientId) {

        Invoice invoice = invoiceRepository
                .findByPatientIdAndStatus(patientId, InvoiceStatus.OPEN)
                .orElseGet(() -> createInvoice(patientId));

        invoice.getItems().size();
        return invoice;
    }

    // ================================
    // ADD ITEM
    // ================================
    @Override
    @Transactional
    public InvoiceItem addServiceItem(
            Long invoiceId,
            String itemName,
            Integer quantity,
            Double price) {

        Invoice invoice = invoiceRepository.findById(invoiceId)
                .orElseThrow(() -> new RuntimeException("Invoice not found"));

        InvoiceItem item = new InvoiceItem();

        int safeQty = quantity != null ? quantity : 0;
        double safePrice = price != null ? price : 0.0;

        item.setInvoice(invoice);
        item.setItemName(itemName);
        item.setQuantity(safeQty);
        item.setPrice(safePrice);
        item.setTotal(safeQty * safePrice);

        itemRepository.save(item);

        double current = invoice.getTotalAmount() != null ? invoice.getTotalAmount() : 0.0;
        invoice.setTotalAmount(current + item.getTotal());

        invoiceRepository.save(invoice);
        invoice.getItems().size();

        return item;
    }

    @Override
    @Transactional
    public InvoiceItem addItemByVisit(
            Long visitId,
            String itemName,
            Integer quantity,
            Double price) {

        Invoice invoice = getOrCreateByVisit(visitId);

        return addServiceItem(
                invoice.getId(),
                itemName,
                quantity,
                price
        );
    }

    // ================================
    // CLOSE INVOICE
    // ================================
    @Override
    @Transactional
    public Invoice closeInvoice(Long invoiceId) {

        Invoice invoice = invoiceRepository.findById(invoiceId)
                .orElseThrow(() -> new RuntimeException("Invoice not found"));

        invoice.setStatus(InvoiceStatus.CLOSED);

        Invoice saved = invoiceRepository.save(invoice);
        saved.getItems().size();

        return saved;
    }

    // ================================
    // 💳 PAYMENT
    // ================================
    @Override
    @Transactional
    public Invoice makePayment(Long invoiceId, Double amount) {

        Invoice invoice = invoiceRepository.findById(invoiceId)
                .orElseThrow(() -> new RuntimeException("Invoice not found"));

        double paid = invoice.getPaidAmount() != null ? invoice.getPaidAmount() : 0.0;
        paid += (amount != null ? amount : 0.0);

        invoice.setPaidAmount(paid);

        double total = invoice.getTotalAmount() != null ? invoice.getTotalAmount() : 0.0;

        if (paid >= total) {
            invoice.setPaymentStatus(PaymentStatus.PAID);
        } else if (paid > 0) {
            invoice.setPaymentStatus(PaymentStatus.PARTIAL);
        } else {
            invoice.setPaymentStatus(PaymentStatus.PENDING);
        }

        Invoice saved = invoiceRepository.save(invoice);
        saved.getItems().size();

        sendPaymentEmail(saved, amount);

        return saved;
    }

    // ================================
    // 📧 INVOICE CREATED EMAIL
    // ================================
    private void sendInvoiceCreatedEmail(Invoice invoice) {

        try {
            String email = invoice.getPatient().getEmail();
            if (email == null || email.isBlank()) return;

            byte[] pdf = billingPdfService.generateInvoicePdf(invoice.getId());

            String path = System.getProperty("java.io.tmpdir")
                    + "/invoice_" + invoice.getId() + ".pdf";

            Files.write(Paths.get(path), pdf);

            String patientName = invoice.getPatient().getFirstName();

            String subject = "Invoice Created - CareConnect";

            String body = """
            <html>
            <body>
                <h2>🧾 Invoice Created</h2>
                <p>Dear %s,</p>
                <p>Your bill has been created.</p>
                <p>Status: %s</p>
                <p>Total: ₹%.2f</p>
            </body>
            </html>
            """.formatted(
                    patientName,
                    invoice.getPaymentStatus().name(),
                    invoice.getTotalAmount() != null ? invoice.getTotalAmount() : 0.0
            );

            emailService.sendEmailWithAttachment(email, subject, body, path);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ================================
    // 📧 PAYMENT EMAIL
    // ================================
    private void sendPaymentEmail(Invoice invoice, Double amount) {

        try {
            String email = invoice.getPatient().getEmail();
            if (email == null || email.isBlank()) return;

            byte[] pdf = billingPdfService.generateInvoicePdf(invoice.getId());

            String path = System.getProperty("java.io.tmpdir")
                    + "/invoice_" + invoice.getId() + ".pdf";

            Files.write(Paths.get(path), pdf);

            String patientName = invoice.getPatient().getFirstName();

            double total = invoice.getTotalAmount() != null ? invoice.getTotalAmount() : 0.0;
            double paid = invoice.getPaidAmount() != null ? invoice.getPaidAmount() : 0.0;
            double remaining = total - paid;

            String subject = "Payment Receipt - CareConnect";

            String body = """
            <html>
            <body>
                <h2>💳 Payment Receipt</h2>
                <p>Dear %s,</p>
                <p>Paid: ₹%.2f</p>
                <p>Total: ₹%.2f</p>
                <p>Remaining: ₹%.2f</p>
            </body>
            </html>
            """.formatted(patientName, amount, total, remaining);

            emailService.sendEmailWithAttachment(email, subject, body, path);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<Invoice> getAllInvoices() {
        List<Invoice> list = invoiceRepository.findAll();
        list.forEach(inv -> inv.getItems().size());
        return list;
    }

    @Override
    @Transactional(readOnly = true)
    public Invoice getInvoiceByPatient(Long patientId) {

        Invoice invoice = invoiceRepository
                .findByPatientIdAndStatus(patientId, InvoiceStatus.OPEN)
                .orElseThrow(() -> new RuntimeException("No active invoice"));

        invoice.getItems().size();
        return invoice;
    }

    @Override
    @Transactional(readOnly = true)
    public Double getTodayRevenue() {

        LocalDateTime startOfDay = LocalDateTime.now().toLocalDate().atStartOfDay();
        LocalDateTime endOfDay = startOfDay.plusDays(1);

        Double val = invoiceRepository.getTodayRevenue(startOfDay, endOfDay);
        return val != null ? val : 0.0;
    }
}