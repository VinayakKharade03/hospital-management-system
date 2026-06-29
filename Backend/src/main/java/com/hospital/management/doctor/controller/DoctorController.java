package com.hospital.management.doctor.controller;

import com.hospital.management.doctor.dto.*;
import com.hospital.management.doctor.service.DoctorAvailabilityService;
import com.hospital.management.doctor.service.DoctorService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/doctors")
@RequiredArgsConstructor
public class DoctorController {

    private final DoctorService doctorService;
    private final DoctorAvailabilityService availabilityService;

    // --------------------------------
    // DOCTOR MANAGEMENT
    // --------------------------------

    // ADMIN creates doctor accounts
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping
    public DoctorResponse createDoctor(@Valid @RequestBody DoctorRequest request) {
        return doctorService.createDoctor(request);
    }

    // Only ADMIN can view all doctors
    @PreAuthorize("hasAnyRole('ADMIN','RECEPTIONIST')")
    @GetMapping
    public Page<DoctorResponse> getAllDoctors(Pageable pageable) {
        return doctorService.getAllDoctors(pageable);
    }

    // ADMIN and DOCTOR can view doctor profile
    @PreAuthorize("hasAnyRole('ADMIN','DOCTOR')")
    @GetMapping("/{doctorId}")
    public DoctorResponse getDoctorById(@PathVariable Long doctorId) {
        return doctorService.getDoctorById(doctorId);
    }

    // Only ADMIN updates doctor
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{doctorId}")
    public DoctorResponse updateDoctor(
            @PathVariable Long doctorId,
            @Valid @RequestBody DoctorRequest request) {

        return doctorService.updateDoctor(doctorId, request);
    }

    // Only ADMIN deletes doctor
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{doctorId}")
    public void deleteDoctor(@PathVariable Long doctorId) {
        doctorService.deleteDoctor(doctorId);
    }

    // --------------------------------
    // DOCTOR AVAILABILITY
    // --------------------------------

    // ADMIN or DOCTOR can add availability schedule
    @PreAuthorize("hasAnyRole('ADMIN','DOCTOR')")
    @PostMapping("/{doctorId}/availability")
    public AvailabilityResponse addAvailability(
            @PathVariable Long doctorId,
            @Valid @RequestBody AvailabilityRequest request) {

        return availabilityService.addAvailability(doctorId, request);
    }

    // ADMIN / DOCTOR / RECEPTIONIST can view availability
    @PreAuthorize("hasAnyRole('ADMIN','DOCTOR','RECEPTIONIST')")
    @GetMapping("/{doctorId}/availability")
    public List<AvailabilityResponse> getAvailability(
            @PathVariable Long doctorId) {

        return availabilityService.getDoctorAvailability(doctorId);
    }
}