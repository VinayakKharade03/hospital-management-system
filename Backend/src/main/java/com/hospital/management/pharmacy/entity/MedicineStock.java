package com.hospital.management.pharmacy.entity;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
public class MedicineStock {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "medicine_id")
    private Medicine medicine;

    private int quantity;

    private String batchNumber;

    private LocalDate mfgDate;

    private LocalDate expiryDate;

    private String supplierName;

    // =========================
    // GETTERS & SETTERS
    // =========================

    public Long getId() { return id; }

    public Medicine getMedicine() { return medicine; }

    public void setMedicine(Medicine medicine) { this.medicine = medicine; }

    public int getQuantity() { return quantity; }

    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getBatchNumber() { return batchNumber; }

    public void setBatchNumber(String batchNumber) { this.batchNumber = batchNumber; }

    public LocalDate getMfgDate() { return mfgDate; }

    public void setMfgDate(LocalDate mfgDate) { this.mfgDate = mfgDate; }

    public LocalDate getExpiryDate() { return expiryDate; }

    public void setExpiryDate(LocalDate expiryDate) { this.expiryDate = expiryDate; }

    public String getSupplierName() { return supplierName; }

    public void setSupplierName(String supplierName) { this.supplierName = supplierName; }
}