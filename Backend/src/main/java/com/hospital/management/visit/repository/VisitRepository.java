package com.hospital.management.visit.repository;

import com.hospital.management.visit.entity.Visit;
import com.hospital.management.visit.enums.VisitStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface VisitRepository extends JpaRepository<Visit, Long> {

    List<Visit> findByPatientId(Long patientId);

    boolean existsByAppointmentIdAndStatus(Long appointmentId, VisitStatus status);

    Optional<Visit> findByAppointmentId(Long appointmentId);
}