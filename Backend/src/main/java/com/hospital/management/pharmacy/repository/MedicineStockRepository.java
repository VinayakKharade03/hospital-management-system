package com.hospital.management.pharmacy.repository;

import com.hospital.management.pharmacy.entity.MedicineStock;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;

public interface MedicineStockRepository extends JpaRepository<MedicineStock, Long> {

    List<MedicineStock> findByMedicineIdOrderByExpiryDateAsc(Long medicineId);

    List<MedicineStock> findByMedicineId(Long medicineId);

    List<MedicineStock> findByExpiryDateBefore(LocalDate date);

    // 🟢 Add these two query derivation hooks:
    List<MedicineStock> findByMedicineIdAndQuantityGreaterThanAndExpiryDateAfter(Long medicineId, int quantity, LocalDate expiryDate);

    List<MedicineStock> findByQuantityGreaterThanAndExpiryDateAfter(int quantity, LocalDate expiryDate);
}