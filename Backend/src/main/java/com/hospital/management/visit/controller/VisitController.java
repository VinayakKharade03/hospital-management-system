package com.hospital.management.visit.controller;

import com.hospital.management.visit.dto.VisitRequest;
import com.hospital.management.visit.dto.VisitResponse;
import com.hospital.management.visit.service.VisitService;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/visits")
public class VisitController {

    private final VisitService visitService;

    public VisitController(VisitService visitService) {
        this.visitService = visitService;
    }

    @PreAuthorize("hasRole('RECEPTIONIST')")
    @PostMapping("/checkin")
    public VisitResponse checkIn(@RequestBody VisitRequest request) {
        return visitService.checkIn(request);
    }

    @GetMapping("/{id}")
    public VisitResponse getVisit(@PathVariable Long id) {
        return visitService.getVisit(id);
    }


    @GetMapping("/by-appointment/{appointmentId}")          // ADD THIS WHOLE METHOD
    public VisitResponse getVisitByAppointment(@PathVariable Long appointmentId) {
        return visitService.getVisitByAppointmentId(appointmentId);
    }

    @GetMapping("/patient/{patientId}")
    public List<VisitResponse> getPatientVisits(@PathVariable Long patientId) {
        return visitService.getPatientVisits(patientId);
    }
}