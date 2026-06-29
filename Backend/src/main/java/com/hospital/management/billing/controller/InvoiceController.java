package com.hospital.management.billing.controller;

import com.hospital.management.billing.dto.*;
import com.hospital.management.billing.entity.*;
import com.hospital.management.billing.service.InvoiceService;
import com.hospital.management.billing.service.BillingPdfService;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/billing")
public class InvoiceController {

    private final InvoiceService service;
    private final BillingPdfService pdfService;

    public InvoiceController(InvoiceService service, BillingPdfService pdfService) {
        this.service = service;
        this.pdfService = pdfService;
    }

    // ================================
    // CREATE BY PATIENT
    // ================================

    @PostMapping("/create/{patientId}")
    @PreAuthorize("hasAnyRole('ADMIN','RECEPTIONIST')")
    public InvoiceResponse createInvoice(@PathVariable Long patientId) {
        return map(service.createInvoice(patientId));
    }

    // ================================
    // CREATE BY VISIT (AUTO)
    // ================================

    @PostMapping("/visit/{visitId}")
    @PreAuthorize("hasAnyRole('ADMIN','RECEPTIONIST')")
    public InvoiceResponse createByVisit(@PathVariable Long visitId) {
        return map(service.getOrCreateByVisit(visitId));
    }

    // ================================
    // ADD ITEM (DIRECT)
    // ================================

    @PostMapping("/add-item/{invoiceId}")
    @PreAuthorize("hasAnyRole('ADMIN','PHARMACIST','LAB_TECHNICIAN')")
    public InvoiceItemResponse addItem(
            @PathVariable Long invoiceId,
            @RequestBody AddItemRequest request) {

        return mapItem(service.addServiceItem(
                invoiceId,
                request.getItemName(),
                request.getQuantity(),
                request.getPrice()
        ));
    }

    // ================================
    // ADD ITEM (AUTO VISIT)
    // ================================

    @PostMapping("/visit/add-item/{visitId}")
    @PreAuthorize("hasAnyRole('ADMIN','PHARMACIST','LAB')")
    public InvoiceItemResponse addItemByVisit(
            @PathVariable Long visitId,
            @RequestBody AddItemRequest request) {

        return mapItem(service.addItemByVisit(
                visitId,
                request.getItemName(),
                request.getQuantity(),
                request.getPrice()
        ));
    }

    // ================================
    // PAYMENT
    // ================================

    @PostMapping("/pay/{invoiceId}")
    @PreAuthorize("hasAnyRole('ADMIN','RECEPTIONIST')")
    public InvoiceResponse pay(@PathVariable Long invoiceId,
                               @RequestParam Double amount) {

        return map(service.makePayment(invoiceId, amount));
    }

    // ================================
    // CLOSE
    // ================================

    @PostMapping("/close/{invoiceId}")
    @PreAuthorize("hasAnyRole('ADMIN','RECEPTIONIST')")
    public InvoiceResponse close(@PathVariable Long invoiceId) {
        return map(service.closeInvoice(invoiceId));
    }

    // ================================
    // GET ALL (ADMIN ONLY)
    // ================================

    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    public List<InvoiceResponse> getAll() {

        return service.getAllInvoices()
                .stream()
                .map(this::map)
                .collect(Collectors.toList());
    }

    // ================================
    // PDF
    // ================================

    @GetMapping("/invoice/{id}/pdf")
    public ResponseEntity<byte[]> downloadPdf(@PathVariable Long id) {

        byte[] pdf = pdfService.generateInvoicePdf(id);

        return ResponseEntity.ok()
                .header("Content-Type", "application/pdf")
                .header("Content-Disposition", "attachment; filename=invoice_" + id + ".pdf")
                .body(pdf);
    }

    // ================================
    // REVENUE
    // ================================

    @GetMapping("/revenue/today")
    @PreAuthorize("hasRole('ADMIN')")
    public Double revenue() {
        return service.getTodayRevenue();
    }

    // ================================
    // ===== DTO MAPPER =====
    // ================================

    private InvoiceResponse map(Invoice invoice) {

        InvoiceResponse res = new InvoiceResponse();

        res.setId(invoice.getId());
        res.setPatientName(
                invoice.getPatient().getFirstName() + " " +
                        invoice.getPatient().getLastName()
        );
        res.setTotalAmount(invoice.getTotalAmount());
        res.setStatus(invoice.getStatus().name());
        res.setPaymentStatus(invoice.getPaymentStatus().name());
        res.setPaidAmount(invoice.getPaidAmount());

        List<InvoiceItemResponse> items = invoice.getItems()
                .stream()
                .map(this::mapItem)
                .collect(Collectors.toList());

        res.setItems(items);

        return res;
    }

    private InvoiceItemResponse mapItem(InvoiceItem item) {

        InvoiceItemResponse res = new InvoiceItemResponse();

        res.setItemName(item.getItemName());
        res.setQuantity(item.getQuantity());
        res.setPrice(item.getPrice());
        res.setTotal(item.getTotal());

        return res;
    }
}