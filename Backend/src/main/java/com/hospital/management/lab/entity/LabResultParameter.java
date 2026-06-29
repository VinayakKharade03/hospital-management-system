package com.hospital.management.lab.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "lab_result_parameters")
public class LabResultParameter {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String parameterName;

    private String value;

    private String unit;

    private String normalRange;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private LabTestOrder order;

    public LabResultParameter() {}

    public Long getId() { return id; }

    public String getParameterName() { return parameterName; }

    public String getValue() { return value; }

    public String getUnit() { return unit; }

    public String getNormalRange() { return normalRange; }

    public LabTestOrder getOrder() { return order; }

    public void setId(Long id) { this.id = id; }

    public void setParameterName(String parameterName) { this.parameterName = parameterName; }

    public void setValue(String value) { this.value = value; }

    public void setUnit(String unit) { this.unit = unit; }

    public void setNormalRange(String normalRange) { this.normalRange = normalRange; }

    public void setOrder(LabTestOrder order) { this.order = order; }
}