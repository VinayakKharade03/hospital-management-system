package com.hospital.management.doctor.repository;

import com.hospital.management.doctor.entity.DoctorAvailability;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.util.List;
import java.util.Optional;

public interface DoctorAvailabilityRepository extends JpaRepository<DoctorAvailability, Long> {

    List<DoctorAvailability> findByDoctorId(Long doctorId);

    Optional<DoctorAvailability> findByDoctorIdAndDayOfWeek(
            Long doctorId,
            DayOfWeek dayOfWeek
    );

    @Modifying
    @Transactional
    void deleteByDoctorIdAndDayOfWeek(Long doctorId, DayOfWeek dayOfWeek);
}