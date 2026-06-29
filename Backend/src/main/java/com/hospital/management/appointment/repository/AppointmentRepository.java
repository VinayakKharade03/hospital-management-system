package com.hospital.management.appointment.repository;

import com.hospital.management.appointment.entity.Appointment;
import com.hospital.management.doctor.entity.Doctor;
import com.hospital.management.patient.entity.Patient;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface AppointmentRepository extends JpaRepository<Appointment, Long> {

    // 🔥 Prevent double booking
    boolean existsByDoctorAndAppointmentTime(
            Doctor doctor,
            LocalDateTime appointmentTime
    );

    // ✅ FETCH relations (safe for DTO mapping)
    @EntityGraph(attributePaths = {"patient", "doctor"})
    @Query("SELECT a FROM Appointment a")
    Page<Appointment> findAllWithDetails(Pageable pageable);

    @EntityGraph(attributePaths = {"patient", "doctor"})
    Page<Appointment> findByDoctor(
            Doctor doctor,
            Pageable pageable
    );

    @EntityGraph(attributePaths = {"patient", "doctor"})
    Page<Appointment> findByPatient(
            Patient patient,
            Pageable pageable
    );

    @EntityGraph(attributePaths = {"patient", "doctor"})
    Page<Appointment> findByAppointmentTimeBetween(
            LocalDateTime start,
            LocalDateTime end,
            Pageable pageable
    );

    // 🔥 SINGLE FETCH (CRITICAL FIX)
    @EntityGraph(attributePaths = {"patient", "doctor"})
    Optional<Appointment> findWithDetailsById(Long id);

    // ⚡ Used for slot calculation (no need relations)
    List<Appointment> findByDoctorAndAppointmentTimeBetween(
            Doctor doctor,
            LocalDateTime start,
            LocalDateTime end
    );
}