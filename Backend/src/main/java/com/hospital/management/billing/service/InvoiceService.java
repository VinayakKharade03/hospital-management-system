package com.hospital.management.billing.service;

import com.hospital.management.billing.entity.Invoice;
import com.hospital.management.billing.entity.InvoiceItem;

import java.util.List;

public interface InvoiceService {

    // ================================
    // CREATE
    // ================================

    Invoice createInvoice(Long patientId);

    // ================================
    // PATIENT BASED
    // ================================

    Invoice getOrCreateOpenInvoice(Long patientId);

    Invoice getInvoiceByPatient(Long patientId);

    // ================================
    // VISIT BASED (AUTO BILLING)
    // ================================

    Invoice getOrCreateByVisit(Long visitId); // ✅ FIXED

    // ================================
    // ADD ITEMS
    // ================================

    InvoiceItem addServiceItem(
            Long invoiceId,
            String itemName,
            Integer quantity,
            Double price
    );

    InvoiceItem addItemByVisit( // ✅ FIXED
                                Long visitId,
                                String itemName,
                                Integer quantity,
                                Double price
    );

    // ================================
    // BILL MANAGEMENT
    // ================================

    List<Invoice> getAllInvoices();

    Invoice closeInvoice(Long invoiceId);

    Invoice makePayment(Long invoiceId, Double amount);

    // ================================
    // REPORTS
    // ================================

    Double getTodayRevenue();
}