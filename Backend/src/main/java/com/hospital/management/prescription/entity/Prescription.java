package com.hospital.management.prescription.entity;

import com.hospital.management.visit.entity.Visit;
import com.hospital.management.prescription.enums.PrescriptionStatus;
import jakarta.persistence.*;

import java.time.LocalDateTime;
import java.util.List;

@Entity
public class Prescription {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    private Visit visit;

    private LocalDateTime createdAt;

    @Enumerated(EnumType.STRING)
    private PrescriptionStatus status;

    @OneToMany(mappedBy = "prescription", cascade = CascadeType.ALL)
    private List<PrescriptionItem> items;

    // getters setters
    public Long getId() { return id; }

    public Visit getVisit() { return visit; }

    public void setVisit(Visit visit) { this.visit = visit; }

    public LocalDateTime getCreatedAt() { return createdAt; }

    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public PrescriptionStatus getStatus() { return status; }

    public void setStatus(PrescriptionStatus status) { this.status = status; }

    public List<PrescriptionItem> getItems() { return items; }

    public void setItems(List<PrescriptionItem> items) { this.items = items; }
}