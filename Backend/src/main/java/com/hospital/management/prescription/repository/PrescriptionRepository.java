package com.hospital.management.prescription.repository;

import com.hospital.management.prescription.entity.Prescription;
import com.hospital.management.prescription.enums.PrescriptionStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface PrescriptionRepository extends JpaRepository<Prescription, Long> {

    Optional<Prescription> findByVisitId(Long visitId);

    // 🔴 This standard method causes the LazyInitializationException
    List<Prescription> findByStatusNot(PrescriptionStatus status);

    // 🟢 Use this instead! It pulls the prescription and its lazy items in 1 single database trip
    @Query("SELECT DISTINCT p FROM Prescription p LEFT JOIN FETCH p.items WHERE p.status <> :status")
    List<Prescription> findByStatusNotWithItems(@Param("status") PrescriptionStatus status);
}