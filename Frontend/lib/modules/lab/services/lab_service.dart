import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/network/api_client.dart';
import '../models/lab_test_order.dart';
import '../models/lab_result_form_response.dart';
import '../models/lab_result_value_update_request.dart';

class LabService {
  final Dio _dio = ApiClient().dio;

  // --- Catalog Methods ---
  Future<List<Map<String, dynamic>>> getAvailableTests() async {
    try {
      final response = await _dio.get("/lab-tests/catalog");
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception("Failed to fetch lab test catalog: $e");
    }
  }

  // --- Order Methods ---
  Future<LabTestOrder> orderLabTest({required int visitId, required int testId}) async {
    try {
      final response = await _dio.post(
        "/lab-tests/order",
        queryParameters: {"visitId": visitId, "testId": testId},
      );
      return LabTestOrder.fromJson(response.data);
    } catch (e) {
      throw Exception("Error ordering lab test: $e");
    }
  }

  Future<List<LabTestOrder>> getAllOrders() async {
    try {
      final response = await _dio.get("/lab-tests/all");
      return (response.data as List).map((e) => LabTestOrder.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Error fetching lab orders: $e");
    }
  }

  // --- Result & Report Methods ---

  /// Fetches the template/form for a specific order
  Future<LabResultFormResponse> getResultForm(int orderId) async {
    try {
      final response = await _dio.get("/lab-tests/$orderId/result-form");
      return LabResultFormResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to fetch result form: $e");
    }
  }

  /// Submits the final lab values
  Future<void> addResult(int orderId, List<LabResultValueUpdateRequest> results) async {
    try {
      await _dio.post(
        "/lab-tests/$orderId/result",
        data: results.map((r) => r.toJson()).toList(),
      );
    } catch (e) {
      throw Exception("Error adding lab results: $e");
    }
  }

  String reportUrl(int orderId) {
    return "${_dio.options.baseUrl}/lab-tests/$orderId/report";
  }

  Future<String> downloadReport(int orderId) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = "${dir.path}/lab-report-$orderId.pdf";
      await _dio.download("/lab-tests/$orderId/report", filePath);
      return filePath;
    } catch (e) {
      throw Exception("Error downloading report: $e");
    }
  }

  Future<List<LabTestOrder>> getPatientReports(int patientId) async {
    try {
      final response = await _dio.get("/lab-tests/patient/$patientId/reports");
      return (response.data as List).map((e) => LabTestOrder.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Failed to fetch patient reports: $e");
    }
  }
}