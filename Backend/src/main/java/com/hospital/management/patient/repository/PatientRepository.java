package com.hospital.management.patient.repository;

import com.hospital.management.patient.entity.Patient;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PatientRepository extends JpaRepository<Patient, Long> {
    boolean existsByPhone(String phone);
}
