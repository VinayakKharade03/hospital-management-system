package com.hospital.management.pharmacy.service;

import com.hospital.management.pharmacy.entity.MedicineStock;

import java.time.LocalDate;
import java.util.List;

public interface MedicineStockService {

    MedicineStock addStock(
            Long medicineId,
            int quantity,
            String batchNumber,
            LocalDate mfgDate,
            LocalDate expiryDate,
            String supplier
    );

    void dispenseMedicine(Long visitId, Long medicineId, int quantity);

    boolean isLowStock(Long medicineId, int threshold);

    List<MedicineStock> getExpiringMedicines(int days);

    // ============================================
    // AVAILABLE STOCK METHODS (🟢 ADDED)
    // ============================================

    /**
     * Retrieves all active stock batches for a specific medicine that are unexpired and have quantity > 0.
     */
    List<MedicineStock> getAvailableStockByMedicine(Long medicineId);

    /**
     * Retrieves all available stock batches across the entire pharmacy that are unexpired and have quantity > 0.
     */
    List<MedicineStock> getAllAvailableStock();
}