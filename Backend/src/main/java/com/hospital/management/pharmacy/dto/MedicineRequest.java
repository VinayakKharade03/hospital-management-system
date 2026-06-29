package com.hospital.management.pharmacy.dto;

public class MedicineRequest {

    private String name;
    private Double unitPrice;

    // getters setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(Double unitPrice) { this.unitPrice = unitPrice; }
}