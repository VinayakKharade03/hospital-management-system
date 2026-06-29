package com.hospital.management.lab.dto;

import java.time.LocalDateTime;

public class LabTestOrderResponse {

    private Long id;
    private String patientName;
    private String doctorName;
    private String testName;
    private String status; // keep STRING for API
    private LocalDateTime orderedAt;

    public LabTestOrderResponse(Long id,
                                String patientName,
                                String doctorName,
                                String testName,
                                String status,
                                LocalDateTime orderedAt) {

        this.id = id;
        this.patientName = patientName;
        this.doctorName = doctorName;
        this.testName = testName;
        this.status = status;
        this.orderedAt = orderedAt;
    }

    public Long getId() { return id; }
    public String getPatientName() { return patientName; }
    public String getDoctorName() { return doctorName; }
    public String getTestName() { return testName; }
    public String getStatus() { return status; }
    public LocalDateTime getOrderedAt() { return orderedAt; }
}