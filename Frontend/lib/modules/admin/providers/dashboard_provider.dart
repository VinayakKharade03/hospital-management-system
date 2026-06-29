import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  bool isLoading = true;
  String? error;

  int totalDoctors = 0;
  int totalPatients = 0;
  int todaysAppointments = 0;
  double totalRevenue = 0.0;

  DashboardProvider() {
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final stats = await _service.fetchStats();

      totalDoctors = stats.totalDoctors;
      totalPatients = stats.totalPatients;
      todaysAppointments = stats.todaysAppointments;
      totalRevenue = stats.totalRevenue;

      error = null;
    } catch (e) {
      error = "Failed to load dashboard stats. Pull down to retry.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetchStats();
}