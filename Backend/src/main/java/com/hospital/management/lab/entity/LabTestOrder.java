package com.hospital.management.lab.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.hospital.management.lab.enums.LabTestStatus;
import com.hospital.management.visit.entity.Visit;

import jakarta.persistence.*;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "lab_test_orders")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class LabTestOrder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Link to visit
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "visit_id", nullable = true)
    private Visit visit;

    // Which test was ordered
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "test_id", nullable = false)
    private LabTest test;

    // ✅ ENUM INSTEAD OF STRING
    @Enumerated(EnumType.STRING)
    private LabTestStatus status;

    private String reportPath;

    private LocalDateTime orderedAt;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    private List<LabResultParameter> parameters;

    public LabTestOrder() {}

    @PrePersist
    public void prePersist() {

        this.orderedAt = LocalDateTime.now();

        // ✅ DEFAULT ENUM VALUE
        if (this.status == null) {
            this.status = LabTestStatus.ORDERED;
        }
    }

    public Long getId() { return id; }

    public Visit getVisit() { return visit; }

    public LabTest getTest() { return test; }

    public LabTestStatus getStatus() { return status; }

    public String getReportPath() { return reportPath; }

    public LocalDateTime getOrderedAt() { return orderedAt; }

    public List<LabResultParameter> getParameters() { return parameters; }

    public void setId(Long id) { this.id = id; }

    public void setVisit(Visit visit) { this.visit = visit; }

    public void setTest(LabTest test) { this.test = test; }

    public void setStatus(LabTestStatus status) { this.status = status; }

    public void setReportPath(String reportPath) { this.reportPath = reportPath; }

    public void setOrderedAt(LocalDateTime orderedAt) { this.orderedAt = orderedAt; }

    public void setParameters(List<LabResultParameter> parameters) { this.parameters = parameters; }
}