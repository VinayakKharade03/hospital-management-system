package com.hospital.management.pharmacy.entity;

import com.hospital.management.pharmacy.enums.StockTransactionType;
import com.hospital.management.visit.entity.Visit;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
public class StockTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Medicine medicine;

    private Integer quantity;

    // ✅ ENUM INSTEAD OF STRING
    @Enumerated(EnumType.STRING)
    private StockTransactionType type;

    private LocalDateTime date;

    private String note;

    @ManyToOne
    private Visit visit;

    // =========================
    // GETTERS & SETTERS
    // =========================

    public Long getId() { return id; }

    public Medicine getMedicine() { return medicine; }

    public void setMedicine(Medicine medicine) { this.medicine = medicine; }

    public Integer getQuantity() { return quantity; }

    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public StockTransactionType getType() { return type; }

    public void setType(StockTransactionType type) { this.type = type; }

    public LocalDateTime getDate() { return date; }

    public void setDate(LocalDateTime date) { this.date = date; }

    public String getNote() { return note; }

    public void setNote(String note) { this.note = note; }

    public Visit getVisit() { return visit; }

    public void setVisit(Visit visit) { this.visit = visit; }
}