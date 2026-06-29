package com.hospital.management.prescription.controller;

import com.hospital.management.prescription.dto.*;
import com.hospital.management.prescription.service.PrescriptionService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/prescriptions")
public class PrescriptionController {

    private final PrescriptionService service;

    public PrescriptionController(PrescriptionService service) {
        this.service = service;
    }

    // Receptionist/Doctor creates
    @PostMapping
    public ResponseEntity<PrescriptionResponse> create(
            @RequestBody PrescriptionRequest request) {

        return ResponseEntity.ok(service.createPrescription(request));
    }

    // Pharmacy / others read — single prescription for a visit
    @GetMapping("/visit/{visitId}")
    public ResponseEntity<PrescriptionResponse> getByVisit(
            @PathVariable Long visitId) {

        return ResponseEntity.ok(service.getByVisit(visitId));
    }

    // ✅ ADDED — pharmacist queue: all prescriptions not yet fully dispensed
    @GetMapping("/pending")
    public ResponseEntity<List<PrescriptionResponse>> getPending() {
        return ResponseEntity.ok(service.getPending());
    }

}