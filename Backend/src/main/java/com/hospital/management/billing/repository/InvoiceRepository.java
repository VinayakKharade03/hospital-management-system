package com.hospital.management.billing.repository;

import com.hospital.management.billing.entity.Invoice;
import com.hospital.management.billing.enums.InvoiceStatus;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Optional;

public interface InvoiceRepository extends JpaRepository<Invoice, Long> {

    Optional<Invoice> findByVisitId(Long visitId);

    // ✅ FIX: fetch-join items so the collection is initialized before the
    // Hibernate Session closes — prevents LazyInitializationException when
    // the returned Invoice is later read in the controller (e.g. createByVisit).
    @Query("""
        SELECT DISTINCT i FROM Invoice i
        LEFT JOIN FETCH i.items
        WHERE i.visit.id = :visitId
    """)
    Optional<Invoice> findByVisitIdWithItems(@Param("visitId") Long visitId);

    // ✅ FIX: String → Enum
    Optional<Invoice> findByPatientIdAndStatus(Long patientId, InvoiceStatus status);

    // ✅ DAILY REVENUE
    @Query("""
        SELECT COALESCE(SUM(i.totalAmount), 0)
        FROM Invoice i
        WHERE i.createdAt >= :startOfDay
        AND i.createdAt < :endOfDay
    """)
    Double getTodayRevenue(LocalDateTime startOfDay, LocalDateTime endOfDay);

    // ✅ FULL FETCH (PDF FIX)
    @Query("""
        SELECT DISTINCT i FROM Invoice i
        LEFT JOIN FETCH i.items
        LEFT JOIN FETCH i.patient
        LEFT JOIN FETCH i.visit
        WHERE i.id = :id
    """)
    Optional<Invoice> findFullInvoice(@Param("id") Long id);
}