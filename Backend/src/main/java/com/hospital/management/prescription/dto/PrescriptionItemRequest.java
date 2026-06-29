package com.hospital.management.prescription.dto;

public class PrescriptionItemRequest {

    private Long medicineId;
    private String dosage;
    private String frequency;
    private String duration;

    // ✅ ADDED — needed so the doctor can specify how many units to dispense in total
    private int prescribedQuantity;

    // getters setters
    public Long getMedicineId() { return medicineId; }

    public void setMedicineId(Long medicineId) { this.medicineId = medicineId; }

    public String getDosage() { return dosage; }

    public void setDosage(String dosage) { this.dosage = dosage; }

    public String getFrequency() { return frequency; }

    public void setFrequency(String frequency) { this.frequency = frequency; }

    public String getDuration() { return duration; }

    public void setDuration(String duration) { this.duration = duration; }

    // ✅ ADDED
    public int getPrescribedQuantity() { return prescribedQuantity; }

    public void setPrescribedQuantity(int prescribedQuantity) { this.prescribedQuantity = prescribedQuantity; }
}