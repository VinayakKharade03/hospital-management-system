package com.hospital.management.doctor.repository;

import com.hospital.management.doctor.entity.Doctor;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface DoctorRepository extends JpaRepository<Doctor, Long> {

    boolean existsByEmail(String email);

    boolean existsByPhone(String phone);

    Optional<Doctor> findByEmail(String email);

    // ✅ FIXED: because Doctor has User user field
    Optional<Doctor> findByUser_Id(Long id);
}