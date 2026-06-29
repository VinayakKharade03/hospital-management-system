package com.hospital.management.prescription.dto;

import java.util.List;

public class PrescriptionRequest {

    private Long visitId;
    private List<PrescriptionItemRequest> items;

    public Long getVisitId() { return visitId; }

    public void setVisitId(Long visitId) { this.visitId = visitId; }

    public List<PrescriptionItemRequest> getItems() { return items; }

    public void setItems(List<PrescriptionItemRequest> items) {
        this.items = items;
    }
}