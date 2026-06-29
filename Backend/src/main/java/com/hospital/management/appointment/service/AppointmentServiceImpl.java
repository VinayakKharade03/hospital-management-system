package com.hospital.management.appointment.service;

import com.hospital.management.appointment.dto.*;
import com.hospital.management.appointment.entity.Appointment;
import com.hospital.management.appointment.enums.AppointmentStatus;
import com.hospital.management.appointment.repository.AppointmentRepository;
import com.hospital.management.doctor.entity.Doctor;
import com.hospital.management.doctor.repository.DoctorAvailabilityRepository;
import com.hospital.management.doctor.repository.DoctorRepository;
import com.hospital.management.exception.ConflictException;
import com.hospital.management.exception.ResourceNotFoundException;
import com.hospital.management.notification.service.NotificationService;
import com.hospital.management.patient.entity.Patient;
import com.hospital.management.patient.repository.PatientRepository;
import java.time.format.DateTimeFormatter;
import com.hospital.management.visit.repository.VisitRepository;
import com.hospital.management.visit.enums.VisitStatus;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.*;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AppointmentServiceImpl implements AppointmentService {

    private final AppointmentRepository appointmentRepository;
    private final PatientRepository patientRepository;
    private final DoctorRepository doctorRepository;
    private final DoctorAvailabilityRepository availabilityRepository;
    private final NotificationService notificationService;
    private final VisitRepository visitRepository;// 🔥 NEW

    // -------------------------------------
    // CREATE APPOINTMENT
    // -------------------------------------
    @Override
    @Transactional
    public AppointmentResponse createAppointment(AppointmentRequest request) {

        Patient patient = patientRepository.findById(request.getPatientId())
                .orElseThrow(() -> new ResourceNotFoundException("Patient not found"));

        Doctor doctor = doctorRepository.findById(request.getDoctorId())
                .orElseThrow(() -> new ResourceNotFoundException("Doctor not found"));

        DayOfWeek day = request.getAppointmentTime().getDayOfWeek();

        var availability = availabilityRepository
                .findByDoctorIdAndDayOfWeek(request.getDoctorId(), day)
                .orElseThrow(() ->
                        new ConflictException("Doctor is not available on this day"));

        LocalTime appointmentTime = request.getAppointmentTime().toLocalTime();

        if (appointmentTime.isBefore(availability.getStartTime())
                || appointmentTime.isAfter(availability.getEndTime())) {

            throw new ConflictException("Appointment time outside doctor's working hours");
        }

        boolean exists = appointmentRepository
                .existsByDoctorAndAppointmentTime(doctor, request.getAppointmentTime());

        if (exists) {
            throw new ConflictException("Doctor already has an appointment at this time");
        }

        Appointment appointment = Appointment.builder()
                .patient(patient)
                .doctor(doctor)
                .appointmentTime(request.getAppointmentTime())
                .status(AppointmentStatus.SCHEDULED)
                .notes(request.getNotes())
                .build();

        Appointment saved = appointmentRepository.save(appointment);

        // 🔥 SEND EMAIL (BOOKED)
        String email = patient.getEmail();
        if (email != null && !email.isBlank()) {
            try {
                notificationService.sendAppointmentBookedEmail(
                        email,
                        patient.getFirstName(),
                        doctor.getFirstName() + " " + doctor.getLastName(),
                        saved.getAppointmentTime().toString()
                );
            } catch (Exception e) {
                e.printStackTrace(); // don't break flow
            }
        }

        return mapToResponse(saved);
    }

    // -------------------------------------
    // GET ALL
    // -------------------------------------
    @Override
    @Transactional(readOnly = true)
    public Page<AppointmentResponse> getAllAppointments(Pageable pageable) {

        return appointmentRepository.findAllWithDetails(pageable)
                .map(this::mapToResponse);
    }

    // -------------------------------------
    // GET BY ID
    // -------------------------------------
    @Override
    @Transactional(readOnly = true)
    public AppointmentResponse getAppointmentById(Long id) {

        Appointment appointment = appointmentRepository.findWithDetailsById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Appointment not found"));

        return mapToResponse(appointment);
    }

    // -------------------------------------
    // UPDATE STATUS
    // -------------------------------------
    @Override
    @Transactional
    public AppointmentResponse updateStatus(Long id, AppointmentStatus status) {

        Appointment appointment = appointmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Appointment not found"));

        // 🔒 Cannot complete without a check-in visit
        if (status == AppointmentStatus.COMPLETED) {
            boolean checkedIn = visitRepository
                    .existsByAppointmentIdAndStatus(id, VisitStatus.CHECKED_IN);

            if (!checkedIn) {
                throw new ConflictException(
                        "Patient must be checked in before appointment can be marked completed"
                );
            }
        }

        // 🔒 Cannot change status of already completed/cancelled appointments
        if (appointment.getStatus() == AppointmentStatus.COMPLETED ||
                appointment.getStatus() == AppointmentStatus.CANCELLED) {
            throw new ConflictException(
                    "Cannot update a " + appointment.getStatus() + " appointment"
            );
        }

        appointment.setStatus(status);
        Appointment saved = appointmentRepository.save(appointment);

        if (status == AppointmentStatus.CANCELLED) {
            String email = appointment.getPatient().getEmail();
            if (email != null && !email.isBlank()) {
                try {
                    notificationService.sendAppointmentCancelledEmail(
                            email,
                            appointment.getPatient().getFirstName(),
                            appointment.getDoctor().getFirstName() + " " +
                                    appointment.getDoctor().getLastName(),
                            appointment.getAppointmentTime().toString()
                    );
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }

        return mapToResponse(saved);
    }

    // -------------------------------------
    // DELETE
    // -------------------------------------
    @Override
    @Transactional
    public void deleteAppointment(Long id) {

        Appointment appointment = appointmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Appointment not found"));

        appointmentRepository.delete(appointment);
    }

    // -------------------------------------
    // GET BY DOCTOR
    // -------------------------------------
    @Override
    @Transactional(readOnly = true)
    public Page<AppointmentResponse> getByDoctor(Long doctorId, Pageable pageable) {

        Doctor doctor = doctorRepository.findById(doctorId)
                .orElseThrow(() -> new ResourceNotFoundException("Doctor not found"));

        return appointmentRepository.findByDoctor(doctor, pageable)
                .map(this::mapToResponse);
    }

    // -------------------------------------
    // GET BY PATIENT
    // -------------------------------------
    @Override
    @Transactional(readOnly = true)
    public Page<AppointmentResponse> getByPatient(Long patientId, Pageable pageable) {

        Patient patient = patientRepository.findById(patientId)
                .orElseThrow(() -> new ResourceNotFoundException("Patient not found"));

        return appointmentRepository.findByPatient(patient, pageable)
                .map(this::mapToResponse);
    }

    // -------------------------------------
    // GET BY DATE
    // -------------------------------------
    @Override
    @Transactional(readOnly = true)
    public Page<AppointmentResponse> getByDate(LocalDate date, Pageable pageable) {

        LocalDateTime start = date.atStartOfDay();
        LocalDateTime end = date.atTime(23, 59, 59);

        return appointmentRepository
                .findByAppointmentTimeBetween(start, end, pageable)
                .map(this::mapToResponse);
    }

    // -------------------------------------
    // AVAILABLE SLOTS
    // -------------------------------------
    @Override
    @Transactional(readOnly = true)
    public AvailableSlotsResponse getAvailableSlots(Long doctorId, LocalDate date) {

        Doctor doctor = doctorRepository.findById(doctorId)
                .orElseThrow(() -> new ResourceNotFoundException("Doctor not found"));

        DayOfWeek day = date.getDayOfWeek();

        var availability = availabilityRepository
                .findByDoctorIdAndDayOfWeek(doctorId, day)
                .orElseThrow(() ->
                        new ResourceNotFoundException("Doctor not available on this day"));

        LocalTime start = availability.getStartTime();
        LocalTime end = availability.getEndTime();
        int duration = availability.getSlotDurationMinutes();

        LocalDateTime startDateTime = date.atTime(start);
        LocalDateTime endDateTime = date.atTime(end);

        List<Appointment> appointments = appointmentRepository
                .findByDoctorAndAppointmentTimeBetween(doctor, startDateTime, endDateTime);

        Set<LocalTime> bookedSlots = appointments.stream()
                .map(a -> a.getAppointmentTime().toLocalTime())
                .collect(Collectors.toSet());

        List<LocalTime> availableSlots = new ArrayList<>();

        LocalTime slot = start;

        while (slot.isBefore(end)) {

            if (!bookedSlots.contains(slot)) {
                availableSlots.add(slot);
            }

            slot = slot.plusMinutes(duration);
        }

        return AvailableSlotsResponse.builder()
                .doctorId(doctorId)
                .date(date)
                .availableSlots(availableSlots)
                .build();
    }
    // -------------------------------------
    // BOOKED SLOTS
    // -------------------------------------
    @Override
    @Transactional(readOnly = true)
    public List<String> getBookedSlots(Long doctorId, LocalDate date) {

        Doctor doctor = doctorRepository.findById(doctorId)
                .orElseThrow(() -> new ResourceNotFoundException("Doctor not found"));

        DayOfWeek day = date.getDayOfWeek();

        var availability = availabilityRepository
                .findByDoctorIdAndDayOfWeek(doctorId, day)
                .orElse(null);

        int duration = availability != null
                ? availability.getSlotDurationMinutes()
                : 30;

        LocalDateTime startDateTime = date.atStartOfDay();
        LocalDateTime endDateTime = date.atTime(23, 59, 59);

        List<Appointment> appointments = appointmentRepository
                .findByDoctorAndAppointmentTimeBetween(doctor, startDateTime, endDateTime);

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm");

        return appointments.stream()
                .filter(a -> a.getStatus() != AppointmentStatus.CANCELLED)
                .map(a -> {
                    LocalTime start = a.getAppointmentTime().toLocalTime();
                    LocalTime end = start.plusMinutes(duration);
                    return start.format(formatter) + " - " + end.format(formatter);
                })
                .toList();
    }

    // -------------------------------------
    // RESCHEDULE
    // -------------------------------------
    @Override
    @Transactional
    public AppointmentResponse rescheduleAppointment(Long id, LocalDateTime newTime) {

        Appointment appointment = appointmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Appointment not found"));

        Doctor doctor = appointment.getDoctor();

        boolean exists = appointmentRepository
                .existsByDoctorAndAppointmentTime(doctor, newTime);

        if (exists) {
            throw new ConflictException("Doctor already has an appointment at this time");
        }

        appointment.setAppointmentTime(newTime);

        Appointment saved = appointmentRepository.save(appointment);

        // 🔥 SEND EMAIL (RESCHEDULE)
        String email = appointment.getPatient().getEmail();

        if (email != null && !email.isBlank()) {
            try {
                notificationService.sendAppointmentRescheduledEmail(
                        email,
                        appointment.getPatient().getFirstName(),
                        appointment.getDoctor().getFirstName() + " " +
                                appointment.getDoctor().getLastName(),
                        newTime.toString()
                );
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return mapToResponse(saved);
    }

    // -------------------------------------
    // MAPPER
    // -------------------------------------
    private AppointmentResponse mapToResponse(Appointment appointment) {

        return AppointmentResponse.builder()
                .id(appointment.getId())
                .patientId(appointment.getPatient().getId())
                .patientName(
                        appointment.getPatient().getFirstName() + " " +
                                appointment.getPatient().getLastName()
                )
                .doctorId(appointment.getDoctor().getId())
                .doctorName(
                        appointment.getDoctor().getFirstName() + " " +
                                appointment.getDoctor().getLastName()
                )
                .appointmentTime(appointment.getAppointmentTime())
                .status(appointment.getStatus())
                .notes(appointment.getNotes())
                .build();
    }
}