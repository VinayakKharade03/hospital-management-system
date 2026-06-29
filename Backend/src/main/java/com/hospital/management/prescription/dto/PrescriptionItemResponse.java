package com.hospital.management.prescription.dto;

public class PrescriptionItemResponse {

    private Long medicineId;
    private String medicineName;
    private int prescribedQuantity;
    private int dispensedQuantity;
    private boolean fullyDispensed;

    public Long getMedicineId() { return medicineId; }
    public void setMedicineId(Long medicineId) { this.medicineId = medicineId; }

    public String getMedicineName() { return medicineName; }
    public void setMedicineName(String medicineName) { this.medicineName = medicineName; }

    public int getPrescribedQuantity() { return prescribedQuantity; }
    public void setPrescribedQuantity(int prescribedQuantity) { this.prescribedQuantity = prescribedQuantity; }

    public int getDispensedQuantity() { return dispensedQuantity; }
    public void setDispensedQuantity(int dispensedQuantity) { this.dispensedQuantity = dispensedQuantity; }

    public boolean isFullyDispensed() { return fullyDispensed; }
    public void setFullyDispensed(boolean fullyDispensed) { this.fullyDispensed = fullyDispensed; }
}