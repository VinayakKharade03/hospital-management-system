// lib/modules/prescription/service/prescription_service.dart

import 'package:dio/dio.dart';
import '../../prescription/models/PrescriptionResponse.dart'; // 🟢 Local relative import

class PrescriptionService {
  final Dio _dio = Dio();

  // 💡 Reminder: Change 'localhost' to '10.0.2.2' if testing on an Android Emulator
  final String baseUrl = "http://localhost:8080/api/prescriptions";

  Future<void> createPrescription({
    required int visitId,
    required List<Map<String, dynamic>> items,
    required String notes,
    required String token, // 🟢 Added secure token parameter
  }) async {
    try {
      await _dio.post(
        baseUrl,
        data: {
          "visitId": visitId,
          "items": items,
          "notes": notes,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token", // 🟢 Injected secure header
          },
        ),
      );
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception("Backend Error: $errorMessage");
    }
  }

  Future<List<PrescriptionResponse>> getPendingPrescriptions(String token) async { // 🟢 Added secure token parameter
    try {
      final response = await _dio.get(
        "$baseUrl/pending",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token", // 🟢 Injected secure header
          },
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => PrescriptionResponse.fromJson(item)).toList();
      }
      throw Exception("Failed to load pending queue");
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception("Backend Error: $errorMessage");
    }
  }

  Future<PrescriptionResponse> getByVisitId(int visitId, String token) async { // 🟢 Added secure token parameter
    try {
      final response = await _dio.get(
        "$baseUrl/visit/$visitId",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token", // 🟢 Injected secure header
          },
        ),
      );
      if (response.statusCode == 200) {
        return PrescriptionResponse.fromJson(response.data);
      }
      throw Exception("Prescription not found");
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception("Backend Error: $errorMessage");
    }
  }
}