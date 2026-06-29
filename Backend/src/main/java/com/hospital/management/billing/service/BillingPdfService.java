package com.hospital.management.billing.service;

public interface BillingPdfService {
    byte[] generateInvoicePdf(Long invoiceId);
}