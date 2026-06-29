// lib/modules/pharamcy/providers/pharmacy_provider.dart

import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../models/medicine_stock.dart';
import '../service/medicine_service.dart';
import '../service/medicine_stock_service.dart';

// Cross-Module Imports: Keeping prescription logic in its own domain module
import '../../prescription/models/PrescriptionResponse.dart';
import '../../prescription/service/prescription_service.dart';

class PharmacyProvider extends ChangeNotifier {
  final MedicineService _medicineService = MedicineService();
  final MedicineStockService _stockService = MedicineStockService();
  final PrescriptionService _prescriptionService = PrescriptionService();

  bool isLoading = true;
  String? error;                     // Dashboard view error state (Inventory/Medicines)
  String? prescriptionError;         // Isolated prescription error state

  List<Medicine> medicines = [];
  List<MedicineStock> expiringStock = [];
  // 🟢 ADDED: State holder to store unexpired shelf items matching UI requirements
  List<MedicineStock> availableStock = [];

  // Prescription-centric state management fields
  List<PrescriptionResponse> pendingPrescriptions = [];
  PrescriptionResponse? searchedPrescription;
  bool isPrescriptionLoading = false;
  bool isSubmitting = false;

  PharmacyProvider() {
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      medicines = await _medicineService.getAllMedicines();

      // 🟢 ADDED: Hydrate the active inventory cache container from your service layer
      try {
        availableStock = await _stockService.getAvailableStock();
      } catch (_) {
        availableStock = [];
      }

      try {
        expiringStock = await _stockService.getExpiring(30);
      } catch (_) {
        expiringStock = [];
      }
    } catch (e) {
      error = "Failed to load medicines";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔄 Updated refresh button workflow to pass token down safely
  Future<void> refresh(String token) async {
    await fetchAll();
    await fetchPendingQueue(token);
  }

  // ===============================
  // PRESCRIPTION WORKFLOWS
  // ===============================

  /// Fetches the current live queue of active, un-dispensed prescriptions using the JWT footprint
  Future<void> fetchPendingQueue(String token) async {
    try {
      isPrescriptionLoading = true;
      prescriptionError = null; // Clears only prescription-level errors
      notifyListeners();

      pendingPrescriptions = await _prescriptionService.getPendingPrescriptions(token);
    } catch (e) {
      prescriptionError = "Failed to load prescription queue"; // Isolated state pollution
    } finally {
      isPrescriptionLoading = false;
      notifyListeners();
    }
  }

  /// Explicitly look up a single specific visit ID from the search input bar securely
  Future<void> searchPrescriptionByVisit(int visitId, String token) async {
    try {
      isPrescriptionLoading = true;
      searchedPrescription = null;
      prescriptionError = null; // Clears only prescription-level errors
      notifyListeners();

      searchedPrescription = await _prescriptionService.getByVisitId(visitId, token);
    } catch (e) {
      prescriptionError = "No active prescription found for Visit ID $visitId"; // Isolated state pollution
    } finally {
      isPrescriptionLoading = false;
      notifyListeners();
    }
  }

  /// Iterates and deducts stock counts for an entire prescribed package order securely
  Future<bool> dispenseEntirePrescription(
      PrescriptionResponse prescription,
      String token,
      Map<int, int> quantityOverrides,   // NEW
      ) async {
    try {
      isSubmitting = true;
      notifyListeners();

      for (var item in prescription.items) {
        final qty = quantityOverrides[item.medicineId] ?? item.prescribedQuantity;
        await _stockService.dispense(
          visitId: prescription.visitId,
          medicineId: item.medicineId,
          quantity: qty,
        );
      }
      await fetchAll();
      await fetchPendingQueue(token);
      return true;
    } catch (e) {
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }


  // ===============================
  // ADD MEDICINE
  // ===============================
  Future<bool> addMedicine(String name, double? unitPrice) async {
    try {
      isSubmitting = true;
      notifyListeners();

      await _medicineService.addMedicine(name: name, unitPrice: unitPrice);
      await fetchAll();
      return true;
    } catch (e) {
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  // ===============================
  // DELETE MEDICINE
  // ===============================
  Future<bool> deleteMedicine(int id) async {
    try {
      await _medicineService.deleteMedicine(id);
      medicines.removeWhere((m) => m.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ===============================
  // ADD STOCK
  // ===============================
  Future<bool> addStock({
    required int medicineId,
    required int quantity,
    required String batchNumber,
    required DateTime mfgDate,
    required DateTime expiryDate,
    required String supplier,
  }) async {
    try {
      isSubmitting = true;
      notifyListeners();

      await _stockService.addStock(
        medicineId: medicineId,
        quantity: quantity,
        batchNumber: batchNumber,
        mfgDate: mfgDate,
        expiryDate: expiryDate,
        supplier: supplier,
      );
      await fetchAll();
      return true;
    } catch (e) {
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  // ===============================
  // SINGLE DISPENSE (Fallback)
  // ===============================
  Future<bool> dispense({
    required int visitId,
    required int medicineId,
    required int quantity,
  }) async {
    try {
      isSubmitting = true;
      notifyListeners();

      await _stockService.dispense(
        visitId: visitId,
        medicineId: medicineId,
        quantity: quantity,
      );

      // Re-fetch all inventory counts to keep tracking metrics fully aligned
      await fetchAll();
      return true;
    } catch (e) {
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}