package com.hospital.management.prescription.service;

import com.hospital.management.prescription.dto.PrescriptionRequest;
import com.hospital.management.prescription.dto.PrescriptionResponse;

import java.util.List;

public interface PrescriptionService {

    PrescriptionResponse createPrescription(PrescriptionRequest request);

    PrescriptionResponse getByVisit(Long visitId);

    // ✅ ADDED — backs the pharmacist's pending-prescriptions queue
    List<PrescriptionResponse> getPending();
}