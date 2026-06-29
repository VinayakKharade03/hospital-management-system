package com.hospital.management.billing.dto;

import java.util.List;

public class InvoiceResponse {

    private Long id;
    private String patientName;
    private Double totalAmount;
    private String status;
    private String paymentStatus;
    private Double paidAmount;
    private List<InvoiceItemResponse> items;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public Double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(Double totalAmount) { this.totalAmount = totalAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public Double getPaidAmount() { return paidAmount; }
    public void setPaidAmount(Double paidAmount) { this.paidAmount = paidAmount; }

    public List<InvoiceItemResponse> getItems() { return items; }
    public void setItems(List<InvoiceItemResponse> items) { this.items = items; }
}