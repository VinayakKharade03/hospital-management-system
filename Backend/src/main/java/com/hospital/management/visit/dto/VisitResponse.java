package com.hospital.management.visit.dto;

import java.time.LocalDateTime;

public class VisitResponse {

    private Long visitId;
    private Long patientId;      // 🟢 Added
    private Long doctorId;       // 🟢 Added
    private Long appointmentId;  // 🟢 Added
    private String patientName;
    private String doctorName;
    private String status;
    private LocalDateTime checkInTime;

    // Updated Constructor
    public VisitResponse(Long visitId, Long patientId, Long doctorId, Long appointmentId,
                         String patientName, String doctorName, String status, LocalDateTime checkInTime) {
        this.visitId = visitId;
        this.patientId = patientId;
        this.doctorId = doctorId;
        this.appointmentId = appointmentId;
        this.patientName = patientName;
        this.doctorName = doctorName;
        this.status = status;
        this.checkInTime = checkInTime;
    }

    // Getters
    public Long getVisitId() {
        return visitId;
    }

    public Long getPatientId() { // 🟢 Added
        return patientId;
    }

    public Long getDoctorId() {  // 🟢 Added
        return doctorId;
    }

    public Long getAppointmentId() { // 🟢 Added
        return appointmentId;
    }

    public String getPatientName() {
        return patientName;
    }

    public String getDoctorName() {
        return doctorName;
    }

    public String getStatus() {
        return status;
    }

    public LocalDateTime getCheckInTime() {
        return checkInTime;
    }
}