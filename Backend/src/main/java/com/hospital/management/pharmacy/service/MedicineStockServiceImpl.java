package com.hospital.management.pharmacy.service;

import com.hospital.management.billing.service.BillingPdfService;
import com.hospital.management.billing.service.InvoiceService;
import com.hospital.management.notification.service.NotificationService;
import com.hospital.management.pharmacy.entity.*;
import com.hospital.management.pharmacy.enums.StockTransactionType;
import com.hospital.management.pharmacy.repository.*;
import com.hospital.management.prescription.entity.Prescription;
import com.hospital.management.prescription.entity.PrescriptionItem;
import com.hospital.management.prescription.enums.PrescriptionStatus;
import com.hospital.management.prescription.repository.PrescriptionRepository;
import com.hospital.management.visit.entity.Visit;
import com.hospital.management.visit.repository.VisitRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class MedicineStockServiceImpl implements MedicineStockService {

    private final MedicineRepository medicineRepository;
    private final MedicineStockRepository stockRepository;
    private final StockTransactionRepository transactionRepository;
    private final VisitRepository visitRepository;
    private final InvoiceService invoiceService;
    private final PrescriptionRepository prescriptionRepository;
    private final NotificationService notificationService;
    private final BillingPdfService billingPdfService;

    // ============================
    // ADD STOCK
    // ============================
    @Override
    public MedicineStock addStock(
            Long medicineId,
            int quantity,
            String batchNumber,
            LocalDate mfgDate,
            LocalDate expiryDate,
            String supplier) {

        if (quantity <= 0) {
            throw new RuntimeException("Quantity must be greater than 0");
        }

        Medicine medicine = medicineRepository.findById(medicineId)
                .orElseThrow(() -> new RuntimeException("Medicine not found"));

        MedicineStock stock = new MedicineStock();
        stock.setMedicine(medicine);
        stock.setQuantity(quantity);
        stock.setBatchNumber(batchNumber);
        stock.setMfgDate(mfgDate);
        stock.setExpiryDate(expiryDate);
        stock.setSupplierName(supplier);

        MedicineStock saved = stockRepository.save(stock);

        // TRANSACTION
        StockTransaction tx = new StockTransaction();
        tx.setMedicine(medicine);
        tx.setQuantity(quantity);
        tx.setType(StockTransactionType.PURCHASE);
        tx.setDate(LocalDateTime.now());
        tx.setNote("Stock purchased");

        transactionRepository.save(tx);

        return saved;
    }

    // ============================
    // DISPENSE MEDICINE
    // ============================
    @Override
    public void dispenseMedicine(Long visitId, Long medicineId, int quantity) {

        if (quantity <= 0) {
            throw new RuntimeException("Quantity must be greater than 0");
        }

        Visit visit = visitRepository.findById(visitId)
                .orElseThrow(() -> new RuntimeException("Visit not found"));

        Prescription prescription = prescriptionRepository.findByVisitId(visitId)
                .orElseThrow(() -> new RuntimeException("No prescription found"));

        PrescriptionItem targetItem = prescription.getItems().stream()
                .filter(item -> item.getMedicine().getId().equals(medicineId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Medicine not prescribed"));

        int remainingPrescribed = targetItem.getPrescribedQuantity() - targetItem.getDispensedQuantity();
        if (quantity > remainingPrescribed) {
            throw new RuntimeException(
                    "Cannot dispense " + quantity + " units — only " + remainingPrescribed +
                            " unit(s) remain on this prescription item");
        }

        List<MedicineStock> batches =
                stockRepository.findByMedicineIdOrderByExpiryDateAsc(medicineId);

        int remaining = quantity;

        for (MedicineStock batch : batches) {

            if (remaining <= 0) break;
            if (batch.getExpiryDate().isBefore(LocalDate.now())) continue;

            int available = batch.getQuantity();

            if (available >= remaining) {
                batch.setQuantity(available - remaining);
                remaining = 0;
            } else {
                batch.setQuantity(0);
                remaining -= available;
            }

            stockRepository.save(batch);
        }

        if (remaining > 0) {
            throw new RuntimeException("Not enough stock");
        }

        Medicine medicine = medicineRepository.findById(medicineId)
                .orElseThrow(() -> new RuntimeException("Medicine not found"));

        // ============================
        // 💾 TRANSACTION
        // ============================
        StockTransaction tx = new StockTransaction();
        tx.setMedicine(medicine);
        tx.setQuantity(quantity);
        tx.setType(StockTransactionType.SALE);
        tx.setDate(LocalDateTime.now());
        tx.setVisit(visit);
        tx.setNote("Medicine dispensed");

        transactionRepository.save(tx);

        // ============================
        // 📋 PRESCRIPTION ITEM + STATUS UPDATE
        // ============================
        targetItem.setDispensedQuantity(targetItem.getDispensedQuantity() + quantity);

        boolean allFullyDispensed = prescription.getItems().stream()
                .allMatch(item -> item.getDispensedQuantity() >= item.getPrescribedQuantity());

        prescription.setStatus(allFullyDispensed ? PrescriptionStatus.COMPLETED : PrescriptionStatus.PARTIAL);

        prescriptionRepository.save(prescription);

        // ============================
        // 💰 BILLING
        // ============================
        Long invoiceId = invoiceService
                .getOrCreateByVisit(visit.getId())
                .getId();

        invoiceService.addServiceItem(
                invoiceId,
                medicine.getName(),
                quantity,
                medicine.getUnitPrice()
        );

        // ============================
        // 📄 GENERATE PDF + EMAIL
        // ============================
        try {
            byte[] pdf = billingPdfService.generateInvoicePdf(invoiceId);

            Path tempFile = Files.createTempFile("pharmacy-invoice-", ".pdf");
            Files.write(tempFile, pdf);

            String email = visit.getPatient().getEmail();

            if (email != null && !email.isBlank()) {
                String patientName = visit.getPatient().getFirstName() + " " +
                        visit.getPatient().getLastName();

                notificationService.sendPharmacyInvoiceEmail(
                        email,
                        patientName,
                        tempFile.toString()
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ============================
    // LOW STOCK
    // ============================
    @Override
    public boolean isLowStock(Long medicineId, int threshold) {

        int total = stockRepository.findByMedicineId(medicineId)
                .stream()
                .mapToInt(MedicineStock::getQuantity)
                .sum();

        return total < threshold;
    }

    // ============================
    // EXPIRY CHECK
    // ============================
    @Override
    public List<MedicineStock> getExpiringMedicines(int days) {

        LocalDate date = LocalDate.now().plusDays(days);

        return stockRepository.findByExpiryDateBefore(date);
    }

    // ============================
    // AVAILABLE STOCK (🟢 ADDED)
    // ============================
    @Override
    public List<MedicineStock> getAvailableStockByMedicine(Long medicineId) {
        // Fetches active unexpired batches exclusively for the requested medicine
        return stockRepository.findByMedicineIdAndQuantityGreaterThanAndExpiryDateAfter(
                medicineId, 0, LocalDate.now()
        );
    }

    @Override
    public List<MedicineStock> getAllAvailableStock() {
        // Fetches all batches currently sitting on shelves with positive counts
        return stockRepository.findByQuantityGreaterThanAndExpiryDateAfter(
                0, LocalDate.now()
        );
    }
}