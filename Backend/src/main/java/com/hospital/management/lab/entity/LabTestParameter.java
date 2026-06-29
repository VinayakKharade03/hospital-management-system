package com.hospital.management.lab.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "lab_test_parameters")
public class LabTestParameter {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String parameterName;

    private String unit;

    private String normalRange;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "test_id", nullable = false)
    private LabTest labTest;

    public LabTestParameter() {}

    public Long getId() { return id; }

    public String getParameterName() { return parameterName; }

    public String getUnit() { return unit; }

    public String getNormalRange() { return normalRange; }

    public LabTest getLabTest() { return labTest; }

    public void setId(Long id) { this.id = id; }

    public void setParameterName(String parameterName) { this.parameterName = parameterName; }

    public void setUnit(String unit) { this.unit = unit; }

    public void setNormalRange(String normalRange) { this.normalRange = normalRange; }

    public void setLabTest(LabTest labTest) { this.labTest = labTest; }
}