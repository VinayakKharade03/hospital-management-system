package com.hospital.management.lab.dto;

public class LabResultParameterDto {
    private Long id;
    private String parameterName;
    private String value;
    private String unit;
    private String normalRange;

    public LabResultParameterDto(Long id, String parameterName, String value, String unit, String normalRange) {
        this.id = id;
        this.parameterName = parameterName;
        this.value = value;
        this.unit = unit;
        this.normalRange = normalRange;
    }

    public Long getId() { return id; }
    public String getParameterName() { return parameterName; }
    public String getValue() { return value; }
    public String getUnit() { return unit; }
    public String getNormalRange() { return normalRange; }
}