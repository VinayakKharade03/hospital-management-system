package com.hospital.management.lab.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.*;

import java.util.List;

@Entity
@Table(name = "lab_tests")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class LabTest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;



    @Column(nullable = false)
    private String name;

    @Column(length = 1000)
    private String description;

    @Column(nullable = false)
    private Double price;

    // Template parameters for this test
    @OneToMany(mappedBy = "labTest", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore
    private List<LabTestParameter> parameters;

    // Orders created for this test
    @OneToMany(mappedBy = "test", fetch = FetchType.LAZY)
    @JsonIgnore
    private List<LabTestOrder> orders;

    public LabTest() {}

    public LabTest(String name, String description, Double price) {
        this.name = name;
        this.description = description;
        this.price = price;
    }

    public Long getId() { return id; }

    public String getName() { return name; }

    public String getDescription() { return description; }

    public Double getPrice() { return price; }

    public List<LabTestParameter> getParameters() { return parameters; }

    public List<LabTestOrder> getOrders() { return orders; }

    public void setId(Long id) { this.id = id; }

    public void setName(String name) { this.name = name; }

    public void setDescription(String description) { this.description = description; }

    public void setPrice(Double price) { this.price = price; }

    public void setParameters(List<LabTestParameter> parameters) { this.parameters = parameters; }

    public void setOrders(List<LabTestOrder> orders) { this.orders = orders; }
}