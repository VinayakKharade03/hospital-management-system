package com.hospital.management.lab.repository;

import com.hospital.management.lab.entity.LabTestOrder;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface LabTestOrderRepository
        extends JpaRepository<LabTestOrder, Long> {

    @EntityGraph(attributePaths = {
            "visit",
            "visit.patient",
            "visit.doctor",
            "test"
    })
    List<LabTestOrder> findByVisitPatientId(Long patientId);

    @EntityGraph(attributePaths = {
            "visit",
            "visit.patient",
            "visit.doctor",
            "test"
    })
    List<LabTestOrder> findAll();

    @Query("""
        SELECT o FROM LabTestOrder o
        LEFT JOIN FETCH o.visit v
        LEFT JOIN FETCH v.patient
        LEFT JOIN FETCH v.doctor
        LEFT JOIN FETCH o.test
        WHERE o.id = :id
    """)
    Optional<LabTestOrder> findFullOrder(@Param("id") Long id);
}