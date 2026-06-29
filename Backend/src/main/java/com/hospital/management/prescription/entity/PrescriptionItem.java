package com.hospital.management.prescription.entity;

import com.hospital.management.pharmacy.entity.Medicine;
import jakarta.persistence.*;

@Entity
public class PrescriptionItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Prescription prescription;

    @ManyToOne
    private Medicine medicine;

    private String dosage;
    private String frequency;
    private String duration;

    // ✅ NEW FIELDS (VERY IMPORTANT)
    private int prescribedQuantity;
    private int dispensedQuantity;

    // getters setters
    public Long getId() { return id; }

    public Prescription getPrescription() { return prescription; }

    public void setPrescription(Prescription prescription) {
        this.prescription = prescription;
    }

    public Medicine getMedicine() { return medicine; }

    public void setMedicine(Medicine medicine) {
        this.medicine = medicine;
    }

    public String getDosage() { return dosage; }

    public void setDosage(String dosage) { this.dosage = dosage; }

    public String getFrequency() { return frequency; }

    public void setFrequency(String frequency) { this.frequency = frequency; }

    public String getDuration() { return duration; }

    public void setDuration(String duration) { this.duration = duration; }

    public int getPrescribedQuantity() { return prescribedQuantity; }

    public void setPrescribedQuantity(int prescribedQuantity) {
        this.prescribedQuantity = prescribedQuantity;
    }

    public int getDispensedQuantity() { return dispensedQuantity; }

    public void setDispensedQuantity(int dispensedQuantity) {
        this.dispensedQuantity = dispensedQuantity;
    }
}