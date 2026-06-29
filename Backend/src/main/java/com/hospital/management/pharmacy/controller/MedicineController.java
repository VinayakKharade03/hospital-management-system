package com.hospital.management.pharmacy.controller;

import com.hospital.management.pharmacy.dto.MedicineRequest;
import com.hospital.management.pharmacy.dto.MedicineResponse;
import com.hospital.management.pharmacy.service.MedicineService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/pharmacy/medicines")
public class MedicineController {

    private final MedicineService medicineService;

    public MedicineController(MedicineService medicineService) {
        this.medicineService = medicineService;
    }

    // ============================================
    // ADD MEDICINE
    // ============================================
    @PostMapping
    public ResponseEntity<MedicineResponse> addMedicine(
            @RequestBody MedicineRequest request) {

        return ResponseEntity.ok(
                medicineService.addMedicine(request)
        );
    }

    // ============================================
    // GET ALL
    // ============================================
    @GetMapping
    public ResponseEntity<List<MedicineResponse>> getAllMedicines() {

        return ResponseEntity.ok(
                medicineService.getAllMedicines()
        );
    }

    // ============================================
    // GET BY ID
    // ============================================
    @GetMapping("/{id:[0-9]+}")
    public ResponseEntity<MedicineResponse> getMedicine(@PathVariable Long id) {
        return ResponseEntity.ok(
                medicineService.getMedicine(id)
        );
    }

    // ============================================
    // UPDATE
    // ============================================
    @PutMapping("/{id:[0-9]+}")
    public ResponseEntity<MedicineResponse> updateMedicine(
            @PathVariable Long id,
            @RequestBody MedicineRequest request) {

        // 🔥 Reuse same service method (or create separate update if needed)
        MedicineResponse updated = medicineService.addMedicine(request);

        return ResponseEntity.ok(updated);
    }

    // ============================================
    // DELETE
    // ============================================
    @DeleteMapping("/{id:[0-9]+}")
    public ResponseEntity<String> deleteMedicine(@PathVariable Long id) {

        medicineService.deleteMedicine(id);

        return ResponseEntity.ok("Medicine deleted successfully");
    }
    @GetMapping("/search")
    public ResponseEntity<List<MedicineResponse>> searchMedicines(
            @RequestParam String query) {

        return ResponseEntity.ok(
                medicineService.searchMedicines(query)
        );
    }
}