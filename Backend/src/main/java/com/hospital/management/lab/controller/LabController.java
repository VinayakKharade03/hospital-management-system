package com.hospital.management.lab.controller;

import com.hospital.management.lab.dto.LabResultFormResponse;
import com.hospital.management.lab.dto.LabResultValueUpdateRequest;
import com.hospital.management.lab.dto.LabTestOrderResponse;
import com.hospital.management.lab.dto.LabTestResponse;
import com.hospital.management.lab.entity.LabTestOrder;
import com.hospital.management.lab.service.LabService;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/lab-tests")
public class LabController {

    private final LabService labService;

    public LabController(LabService labService) {
        this.labService = labService;
    }

    // =========================
    // DOCTOR ORDERS LAB TEST
    // =========================
    @PreAuthorize("hasRole('DOCTOR')")
    @PostMapping("/order")
    public LabTestOrderResponse orderTest(
            @RequestParam Long visitId,
            @RequestParam Long testId,
            Authentication authentication) {

        String doctorEmail = authentication.getName();

        return labService.orderTest(doctorEmail, visitId, testId);
    }

    // =========================
    // 🔥 NEW: GET RESULT FORM (pre-filled with template params for this order)
    // =========================
    @PreAuthorize("hasRole('LAB_TECHNICIAN')")
    @GetMapping("/{orderId}/result-form")
    public LabResultFormResponse getResultForm(@PathVariable Long orderId) {
        return labService.getResultForm(orderId);
    }

    // =========================
    // LAB TECHNICIAN UPLOAD RESULT
    // 🔥 UPDATED: now accepts {parameterId, value} pairs only
    // =========================
    @PostMapping("/{orderId}/result")
    @PreAuthorize("hasRole('LAB_TECHNICIAN')")
    public String addResult(
            @PathVariable Long orderId,
            @RequestBody List<LabResultValueUpdateRequest> parameters) {

        labService.addResult(orderId, parameters);
        return "Lab result added successfully";
    }

    // =========================
    // DOWNLOAD LAB REPORT (PDF)
    // =========================
    @PreAuthorize("hasAnyRole('RECEPTIONIST','ADMIN','LAB_TECHNICIAN','DOCTOR')")
    @GetMapping("/{orderId}/report")
    public ResponseEntity<byte[]> downloadReport(@PathVariable Long orderId) {

        byte[] pdf = labService.generateReport(orderId);

        return ResponseEntity.ok()
                .header("Content-Disposition", "attachment; filename=lab-report.pdf")
                .header("Content-Type", "application/pdf")
                .body(pdf);
    }

    // =========================
    // PATIENT REPORT HISTORY
    // =========================
    @PreAuthorize("hasAnyRole('ADMIN','RECEPTIONIST')")
    @GetMapping("/patient/{patientId}/reports")
    public List<LabTestOrderResponse> getPatientReports(@PathVariable Long patientId) {
        return labService.getPatientReports(patientId);
    }

    // =========================
    // ALL ORDERS
    // =========================
    @PreAuthorize("hasAnyRole('DOCTOR','LAB_TECHNICIAN')")
    @GetMapping("/all")
    public List<LabTestOrderResponse> getAllOrders() {
        return labService.getAllOrders();
    }
    // =========================
    // GET AVAILABLE TESTS (CATALOG)
    // =========================
    @PreAuthorize("hasAnyRole('DOCTOR', 'LAB_TECHNICIAN')")
    @GetMapping("/catalog")
    public List<LabTestResponse> getAvailableTests() {
        return labService.getAvailableTests();
    }
}