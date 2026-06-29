// lib/modules/lab/providers/lab_provider.dart

import 'package:flutter/material.dart';
import '../models/lab_test_order.dart';
import '../services/lab_service.dart';
import '../models/lab_result_form_response.dart';
import '../models/lab_result_value_update_request.dart';

class LabProvider extends ChangeNotifier {
  final LabService _service = LabService();

  // State for orders
  bool isLoading = true;
  List<LabTestOrder> orders = [];
  String? error;

  // State for test catalog (for the dropdown)
  List<Map<String, dynamic>> availableTests = [];
  bool isFetchingTests = false;

  // State for actions
  bool isSubmitting = false;

  LabProvider() {
    init();
  }

  Future<void> init() async {
    await Future.wait([
      fetchOrders(),
      fetchAvailableTests(),
    ]);
  }

  // --- Order Logic ---

  List<LabTestOrder> get pendingOrders =>
      orders.where((o) => o.status.toUpperCase() != "COMPLETED").toList();

  List<LabTestOrder> get completedOrders =>
      orders.where((o) => o.status.toUpperCase() == "COMPLETED").toList();

  Future<void> fetchOrders() async {
    try {
      isLoading = true;
      notifyListeners();
      orders = await _service.getAllOrders();
      error = null;
    } catch (e) {
      error = "Failed to load lab orders";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- Catalog Logic (New) ---

  Future<void> fetchAvailableTests() async {
    isFetchingTests = true;
    notifyListeners();
    try {
      // Assumes your service returns the list from your SQL query
      availableTests = await _service.getAvailableTests();
    } catch (e) {
      debugPrint("Error fetching test catalog: $e");
    } finally {
      isFetchingTests = false;
      notifyListeners();
    }
  }

  // --- Submission Logic ---
// Update this method in lib/modules/lab/providers/lab_provider.dart
  Future<bool> submitResult(
      int orderId,
      List<LabResultValueUpdateRequest> parameters, // Use the DTO matching your backend
      ) async {
    try {
      isSubmitting = true;
      notifyListeners();

      await _service.addResult(orderId, parameters);
      await fetchOrders();
      return true;
    } catch (e) {
      debugPrint("Submission error: $e");
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchOrders();
    await fetchAvailableTests();
  }
  // Add this to lib/modules/lab/providers/lab_provider.dart

  Future<LabResultFormResponse?> fetchResultForm(int orderId) async {
    try {
      // You'll need to add getResultForm(orderId) to your LabService
      final form = await _service.getResultForm(orderId);
      return form;
    } catch (e) {
      debugPrint("Error fetching result form: $e");
      return null;
    }
  }
}