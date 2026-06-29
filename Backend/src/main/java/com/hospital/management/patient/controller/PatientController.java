package com.hospital.management.patient.controller;

import com.hospital.management.patient.dto.PatientRequest;
import com.hospital.management.patient.dto.PatientResponse;
import com.hospital.management.patient.service.PatientService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/patients")
@RequiredArgsConstructor
public class PatientController {

    private final PatientService patientService;

    // ✅ ADMIN + RECEPTIONIST create patient
    @PreAuthorize("hasAnyRole('ADMIN','RECEPTIONIST')")
    @PostMapping
    public PatientResponse create(@Valid @RequestBody PatientRequest request) {
        return patientService.createPatient(request);
    }

    // ✅ ADMIN + DOCTOR + RECEPTIONIST can view patient
    @PreAuthorize("hasAnyRole('ADMIN','DOCTOR','RECEPTIONIST')")
    @GetMapping("/{id}")
    public PatientResponse getById(@PathVariable Long id) {
        return patientService.getPatientById(id);
    }

    // ✅ ADMIN + DOCTOR + RECEPTIONIST list patients
    @PreAuthorize("hasAnyRole('ADMIN','DOCTOR','RECEPTIONIST')")
    @GetMapping
    public Page<PatientResponse> getAll(Pageable pageable) {
        return patientService.getAllPatients(pageable);
    }

    // ✅ ADMIN + DOCTOR update patient
    @PreAuthorize("hasAnyRole('ADMIN','DOCTOR')")
    @PutMapping("/{id}")
    public PatientResponse update(
            @PathVariable Long id,
            @Valid @RequestBody PatientRequest request) {
        return patientService.updatePatient(id, request);
    }

    // ✅ ONLY ADMIN delete patient (legal compliance)
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        patientService.deletePatient(id);
    }
}