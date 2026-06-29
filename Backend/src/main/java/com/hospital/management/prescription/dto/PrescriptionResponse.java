package com.hospital.management.prescription.dto;

import java.util.List;

public class PrescriptionResponse {

    private Long prescriptionId;
    private Long visitId;                       // ADD
    private String patientName;
    private String doctorName;
    private String status;
    private List<PrescriptionItemResponse> items;  // REPLACE List<String> medicines

    public Long getPrescriptionId() { return prescriptionId; }
    public void setPrescriptionId(Long prescriptionId) { this.prescriptionId = prescriptionId; }

    public Long getVisitId() { return visitId; }
    public void setVisitId(Long visitId) { this.visitId = visitId; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getDoctorName() { return doctorName; }
    public void setDoctorName(String doctorName) { this.doctorName = doctorName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public List<PrescriptionItemResponse> getItems() { return items; }
    public void setItems(List<PrescriptionItemResponse> items) { this.items = items; }
}