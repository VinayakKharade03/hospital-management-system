package com.hospital.management.appointment.controller;

import com.hospital.management.appointment.dto.*;
import com.hospital.management.appointment.enums.AppointmentStatus;
import com.hospital.management.appointment.service.AppointmentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/appointments")
@RequiredArgsConstructor
public class AppointmentController {

    private final AppointmentService appointmentService;

    @PostMapping
    public ResponseEntity<AppointmentResponse> createAppointment(
            @Valid @RequestBody AppointmentRequest request) {

        return ResponseEntity.ok(appointmentService.createAppointment(request));
    }

    @GetMapping
    public ResponseEntity<Page<AppointmentResponse>> getAllAppointments(Pageable pageable) {

        return ResponseEntity.ok(appointmentService.getAllAppointments(pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<AppointmentResponse> getAppointmentById(@PathVariable Long id) {

        return ResponseEntity.ok(appointmentService.getAppointmentById(id));
    }

    @GetMapping("/doctor/{doctorId}")
    public ResponseEntity<Page<AppointmentResponse>> getByDoctor(
            @PathVariable Long doctorId,
            Pageable pageable) {

        return ResponseEntity.ok(appointmentService.getByDoctor(doctorId, pageable));
    }

    @GetMapping("/patient/{patientId}")
    public ResponseEntity<Page<AppointmentResponse>> getByPatient(
            @PathVariable Long patientId,
            Pageable pageable) {

        return ResponseEntity.ok(appointmentService.getByPatient(patientId, pageable));
    }

    @GetMapping("/date")
    public ResponseEntity<Page<AppointmentResponse>> getByDate(
            @RequestParam LocalDate date,
            Pageable pageable) {

        return ResponseEntity.ok(appointmentService.getByDate(date, pageable));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<AppointmentResponse> updateStatus(
            @PathVariable Long id,
            @RequestBody UpdateAppointmentStatusRequest request) {

        return ResponseEntity.ok(
                appointmentService.updateStatus(
                        id,
                        request.getStatus()
                )
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAppointment(@PathVariable Long id) {

        appointmentService.deleteAppointment(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/available-slots")
    public ResponseEntity<AvailableSlotsResponse> getAvailableSlots(
            @RequestParam Long doctorId,
            @RequestParam LocalDate date) {

        return ResponseEntity.ok(appointmentService.getAvailableSlots(doctorId, date));
    }

    @PatchMapping("/{id}/reschedule")
    public AppointmentResponse rescheduleAppointment(
            @PathVariable Long id,
            @RequestParam LocalDateTime newTime) {

        return appointmentService.rescheduleAppointment(id, newTime);
    }
    @GetMapping("/booked")
    public ResponseEntity<List<String>> getBookedSlots(
            @RequestParam Long doctorId,
            @RequestParam LocalDate date) {

        return ResponseEntity.ok(appointmentService.getBookedSlots(doctorId, date));
    }
}