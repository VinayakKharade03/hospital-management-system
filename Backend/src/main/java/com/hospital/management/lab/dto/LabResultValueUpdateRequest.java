package com.hospital.management.lab.dto;

public class LabResultValueUpdateRequest {
    private Long parameterId;
    private String value;

    public LabResultValueUpdateRequest() {}

    public Long getParameterId() { return parameterId; }
    public void setParameterId(Long parameterId) { this.parameterId = parameterId; }
    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }
}