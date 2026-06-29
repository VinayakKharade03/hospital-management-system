package com.hospital.management.billing.repository;

import com.hospital.management.billing.entity.InvoiceItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface InvoiceItemRepository extends JpaRepository<InvoiceItem, Long> {

    // Guard against duplicate doctor-fee lines: returns true if this invoice
    // already has any item whose name contains "Consultation" (case-insensitive).
    // This catches both naming formats:
    //   "Doctor Consultation Fee — Dr. Kulkarni"  (added by getOrCreateByVisit)
    //   "Doctor Consultation - Amittt Kulkarni"   (added by any other service)
    @Query("""
        SELECT COUNT(i) > 0
        FROM InvoiceItem i
        WHERE i.invoice.id = :invoiceId
          AND LOWER(i.itemName) LIKE LOWER(CONCAT('%', :keyword, '%'))
    """)
    boolean existsByInvoiceIdAndItemNameContainingIgnoreCase(
            @Param("invoiceId") Long invoiceId,
            @Param("keyword")   String keyword
    );
}