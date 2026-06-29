package com.hospital.management.pharmacy.dto;

public class DispenseRequest {

    private Long visitId;
    private Long medicineId;
    private int quantity;

    // getters setters
    public Long getVisitId() { return visitId; }
    public void setVisitId(Long visitId) { this.visitId = visitId; }

    public Long getMedicineId() { return medicineId; }
    public void setMedicineId(Long medicineId) { this.medicineId = medicineId; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
}