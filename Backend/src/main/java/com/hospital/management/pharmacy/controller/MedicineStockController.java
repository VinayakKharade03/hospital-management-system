package com.hospital.management.pharmacy.controller;

import com.hospital.management.pharmacy.dto.*;
import com.hospital.management.pharmacy.entity.MedicineStock;
import com.hospital.management.pharmacy.service.MedicineStockService;

import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/pharmacy/stock")
public class MedicineStockController {

    private final MedicineStockService service;

    public MedicineStockController(MedicineStockService service) {
        this.service = service;
    }

    // ============================================
    // ADD STOCK
    // ============================================
    @PostMapping("/add-stock")
    public MedicineStockResponse addStock(@RequestBody AddStockRequest request) {

        MedicineStock stock = service.addStock(
                request.getMedicineId(),
                request.getQuantity(),
                request.getBatchNumber(),
                LocalDate.parse(request.getMfgDate()),
                LocalDate.parse(request.getExpiryDate()),
                request.getSupplier()
        );

        return mapToResponse(stock);
    }

    // ============================================
    // DISPENSE MEDICINE
    // ============================================
    @PostMapping("/dispense")
    public String dispense(@RequestBody DispenseRequest request) {

        service.dispenseMedicine(
                request.getVisitId(),
                request.getMedicineId(),
                request.getQuantity()
        );

        return "Medicine dispensed successfully";
    }

    // ============================================
    // AVAILABLE STOCK (🟢 ADDED)
    // ============================================
    // GET /api/pharmacy/stock/available -> Gets all unexpired stock with qty > 0
    // GET /api/pharmacy/stock/available?medicineId=5 -> Gets stock for specific medicine
    @GetMapping("/available")
    public List<MedicineStockResponse> getAvailableStock(
            @RequestParam(required = false) Long medicineId) {

        List<MedicineStock> stocks;

        if (medicineId != null) {
            stocks = service.getAvailableStockByMedicine(medicineId);
        } else {
            stocks = service.getAllAvailableStock();
        }

        return stocks.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    // ============================================
    // EXPIRING MEDICINES
    // ============================================
    @GetMapping("/expiring")
    public List<MedicineStockResponse> expiring(@RequestParam int days) {

        return service.getExpiringMedicines(days)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    // ============================================
    // LOW STOCK
    // ============================================
    @GetMapping("/low-stock")
    public boolean lowStock(
            @RequestParam Long medicineId,
            @RequestParam int threshold) {

        return service.isLowStock(medicineId, threshold);
    }

    // ============================================
    // MAPPER
    // ============================================
    private MedicineStockResponse mapToResponse(MedicineStock stock) {

        MedicineStockResponse res = new MedicineStockResponse();

        res.setId(stock.getId());
        res.setMedicineName(stock.getMedicine().getName());
        res.setQuantity(stock.getQuantity());
        res.setBatchNumber(stock.getBatchNumber());
        res.setMfgDate(stock.getMfgDate());
        res.setExpiryDate(stock.getExpiryDate());

        return res;
    }
}