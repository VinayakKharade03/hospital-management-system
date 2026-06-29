import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/availability.dart';

class AvailabilityService {
  final Dio dio = ApiClient().dio;

  // ================= CREATE =================
  Future<void> createAvailability({
    required int doctorId,
    required Map<String, dynamic> data,
  }) async {
    if (doctorId <= 0) {
      throw Exception("Invalid doctor ID");
    }

    await dio.post(
      "/doctors/$doctorId/availability",
      data: data,
    );
  }

  // ================= GET =================
  Future<List<Availability>> getAvailability(
      int doctorId,
      ) async {
    if (doctorId <= 0) {
      throw Exception("Invalid doctor ID");
    }

    final response = await dio.get(
      "/doctors/$doctorId/availability",
    );

    final List data = response.data;

    return data
        .map((e) => Availability.fromJson(e))
        .toList();
  }
}