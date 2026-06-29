package com.hospital.management.lab.dto;

public class LabTestResponse {
    private Long id;
    private String name;

    public LabTestResponse(Long id, String name) {
        this.id = id;
        this.name = name;
    }

    // Getters
    public Long getId() { return id; }
    public String getName() { return name; }
}