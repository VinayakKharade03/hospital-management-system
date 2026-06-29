import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class DashboardStats {
  final int totalDoctors;
  final int totalPatients;
  final int todaysAppointments;
  final double totalRevenue;

  DashboardStats({
    required this.totalDoctors,
    required this.totalPatients,
    required this.todaysAppointments,
    required this.totalRevenue,
  });
}

class DashboardService {
  final Dio dio = ApiClient().dio;

  Future<DashboardStats> fetchStats() async {
    // ─── Run all 4 requests in parallel ───────────────────────────────────
    final results = await Future.wait([
      _fetchTotalDoctors(),
      _fetchTotalPatients(),
      _fetchTodaysAppointments(),
      _fetchTodayRevenue(),
    ]);

    return DashboardStats(
      totalDoctors: results[0] as int,
      totalPatients: results[1] as int,
      todaysAppointments: results[2] as int,
      totalRevenue: results[3] as double,
    );
  }

  // ── 1. Total Doctors ─────────────────────────────────────────────────────
  // Fetch page 0 with size 1; Spring returns `totalElements` in the envelope.
  Future<int> _fetchTotalDoctors() async {
    try {
      final res = await dio.get('/doctors', queryParameters: {'page': 0, 'size': 1});
      return (res.data['totalElements'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ── 2. Total Patients ────────────────────────────────────────────────────
  Future<int> _fetchTotalPatients() async {
    try {
      final res = await dio.get('/patients', queryParameters: {'page': 0, 'size': 1});
      return (res.data['totalElements'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ── 3. Today's Appointments ──────────────────────────────────────────────
  // Fetch the first page sorted by appointmentTime desc, then count entries
  // whose date part matches today. For small daily volumes this is accurate;
  // if you later add a backend filter endpoint, swap the call here.
  Future<int> _fetchTodaysAppointments() async {
    try {
      final today = _todayDateString(); // "yyyy-MM-dd"

      final res = await dio.get(
        '/appointments',
        queryParameters: {
          'page': 0,
          'size': 100,             // enough for a single day
          'sort': 'appointmentTime,desc',
        },
      );

      final List content = res.data['content'] ?? [];

      final count = content.where((e) {
        final raw = e['appointmentTime'] as String?;
        return raw != null && raw.startsWith(today);
      }).length;

      return count;
    } catch (_) {
      return 0;
    }
  }

  // ── 4. Today's Revenue ───────────────────────────────────────────────────
  // Calls GET /api/billing/revenue/today  (ADMIN only)
  Future<double> _fetchTodayRevenue() async {
    try {
      final res = await dio.get('/billing/revenue/today');
      return (res.data as num?)?.toDouble() ?? 0.0;
    } catch (_) {
      // Non-admin roles will get a 403 — return 0 gracefully
      return 0.0;
    }
  }

  // ── Helper ───────────────────────────────────────────────────────────────
  String _todayDateString() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}