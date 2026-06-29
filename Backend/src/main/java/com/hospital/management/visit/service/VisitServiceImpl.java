package com.hospital.management.visit.service;

import com.hospital.management.visit.dto.VisitRequest;
import com.hospital.management.visit.dto.VisitResponse;
import com.hospital.management.visit.entity.Visit;
import com.hospital.management.visit.enums.VisitStatus;
import com.hospital.management.visit.repository.VisitRepository;

import com.hospital.management.patient.entity.Patient;
import com.hospital.management.doctor.entity.Doctor;
import com.hospital.management.appointment.entity.Appointment;
import com.hospital.management.appointment.enums.AppointmentStatus;

import com.hospital.management.patient.repository.PatientRepository;
import com.hospital.management.doctor.repository.DoctorRepository;
import com.hospital.management.appointment.repository.AppointmentRepository;

import com.hospital.management.billing.service.InvoiceService;
import com.hospital.management.notification.service.NotificationService;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class VisitServiceImpl implements VisitService {

    private final VisitRepository visitRepository;
    private final PatientRepository patientRepository;
    private final DoctorRepository doctorRepository;
    private final AppointmentRepository appointmentRepository;
    private final InvoiceService invoiceService;
    private final NotificationService notificationService;

    // ============================================
    // 🏥 CHECK-IN
    // ============================================
    @Override
    @Transactional
    public VisitResponse checkIn(VisitRequest request) {

        Patient patient = patientRepository.findById(request.getPatientId())
                .orElseThrow(() -> new RuntimeException("Patient not found"));

        Doctor doctor = doctorRepository.findById(request.getDoctorId())
                .orElseThrow(() -> new RuntimeException("Doctor not found"));

        Appointment appointment = appointmentRepository.findById(request.getAppointmentId())
                .orElseThrow(() -> new RuntimeException("Appointment not found"));

        LocalDateTime now = LocalDateTime.now();

        // ============================================
        // 🚨 VALIDATION
        // ============================================

        // ❌ cancelled or completed
        if (appointment.getStatus() == AppointmentStatus.CANCELLED ||
                appointment.getStatus() == AppointmentStatus.COMPLETED) {
            throw new RuntimeException("Appointment already closed");
        }

        // ❌ appointment must be today
        if (appointment.getAppointmentTime() != null &&
                !appointment.getAppointmentTime()
                        .toLocalDate()
                        .equals(now.toLocalDate())) {

            throw new RuntimeException(
                    "Check-in allowed only on appointment date");
        }

        // ❌ mark NO_SHOW if too late
        if (appointment.getAppointmentTime() != null &&
                appointment.getAppointmentTime().isBefore(now.minusMinutes(30))) {

            appointment.setStatus(AppointmentStatus.NO_SHOW);
            appointmentRepository.save(appointment);

            throw new RuntimeException("Appointment marked as NO_SHOW");
        }

        // ============================================
        // 🏥 CREATE VISIT
        // ============================================
        Visit visit = new Visit();

        visit.setPatient(patient);
        visit.setDoctor(doctor);
        visit.setAppointment(appointment);
        visit.setCheckInTime(now);
        visit.setStatus(VisitStatus.CHECKED_IN);

        Visit saved = visitRepository.save(visit);

        // ============================================
        // 🔥 IMPORTANT: DO NOT TOUCH APPOINTMENT STATUS
        // ============================================
        // Appointment remains SCHEDULED until completed/cancelled/no_show
        // ✅ Mark appointment as CHECKED_IN so doctor knows patient has arrived
        appointment.setStatus(AppointmentStatus.CHECKED_IN);
        appointmentRepository.save(appointment);



        // ============================================
        // 📩 EMAIL NOTIFICATION
        // ============================================
        if (patient.getEmail() != null && !patient.getEmail().isBlank()) {

            try {
                notificationService.sendVisitCheckInEmail(
                        patient.getEmail(),
                        patient.getFirstName(),
                        doctor.getFirstName() + " " + doctor.getLastName(),
                        saved.getCheckInTime().toString()
                );

                log.info("Check-in email sent to {}", patient.getEmail());

            } catch (Exception e) {
                log.error("Failed to send check-in email", e);
            }
        }



        return map(saved);
    }

    // ============================================
    // 🔍 GET VISIT BY ID
    // ============================================
    @Override
    public VisitResponse getVisit(Long id) {

        Visit visit = visitRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Visit not found"));

        return map(visit);
    }

    // ============================================
    // 📋 GET PATIENT VISITS
    // ============================================
    @Override
    public List<VisitResponse> getPatientVisits(Long patientId) {

        return visitRepository.findByPatientId(patientId)
                .stream()
                .map(this::map)
                .toList();
    }
    // ============================================
    // 🔍 GET VISIT BY APPOINTMENT ID          <-- ADD THIS WHOLE BLOCK
    // ============================================
    @Override
    public VisitResponse getVisitByAppointmentId(Long appointmentId) {

        Visit visit = visitRepository.findByAppointmentId(appointmentId)
                .orElseThrow(() -> new RuntimeException("Visit not found for this appointment"));

        return map(visit);
    }

    // ============================================
// 🧠 MAPPER
// ============================================
    private VisitResponse map(Visit visit) {
        return new VisitResponse(
                visit.getId(),                                                    // visitId
                visit.getPatient() != null ? visit.getPatient().getId() : null,   // patientId
                visit.getDoctor() != null ? visit.getDoctor().getId() : null,     // doctorId
                visit.getAppointment() != null ? visit.getAppointment().getId() : null, // appointmentId
                visit.getPatient().getFirstName() + " " + visit.getPatient().getLastName(),
                visit.getDoctor().getFirstName() + " " + visit.getDoctor().getLastName(),
                visit.getStatus().name(),
                visit.getCheckInTime()
        );
    }
}