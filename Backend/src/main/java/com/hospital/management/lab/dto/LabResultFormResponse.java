package com.hospital.management.lab.dto;

import java.util.List;

public class LabResultFormResponse {

    private Long orderId;
    private String testName;
    private String patientName;
    private String doctorName;
    private String status;
    private List<LabResultParameterDto> parameters;

    public LabResultFormResponse(Long orderId,
                                 String testName,
                                 String patientName,
                                 String doctorName,
                                 String status,
                                 List<LabResultParameterDto> parameters) {
        this.orderId = orderId;
        this.testName = testName;
        this.patientName = patientName;
        this.doctorName = doctorName;
        this.status = status;
        this.parameters = parameters;
    }

    public Long getOrderId() { return orderId; }
    public String getTestName() { return testName; }
    public String getPatientName() { return patientName; }
    public String getDoctorName() { return doctorName; }
    public String getStatus() { return status; }
    public List<LabResultParameterDto> getParameters() { return parameters; }
}