import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/doctor.dart';

class DoctorService {
  final Dio dio = ApiClient().dio;

  Future<Map<String, dynamic>> getDoctors(int page) async {
    try {
      final response = await dio.get("/doctors?page=$page&size=10");

      return {
        "data": (response.data['content'] as List)
            .map((e) => Doctor.fromJson(e))
            .toList(),
        "last": response.data['last'],
      };
    } catch (e) {
      throw Exception("Failed to fetch doctors");
    }
  }

  Future<void> createDoctor(Map<String, dynamic> data) async {
    try {
      await dio.post("/doctors", data: data);
    } catch (e) {
      throw Exception("Failed to create doctor");
    }
  }

  Future<void> updateDoctor(int id, Map<String, dynamic> data) async {
    try {
      await dio.put("/doctors/$id", data: data);
    } catch (e) {
      throw Exception("Failed to update doctor");
    }
  }

  Future<void> deleteDoctor(int id) async {
    try {
      await dio.delete("/doctors/$id");
    } catch (e) {
      throw Exception("Failed to delete doctor");
    }
  }
  Future<Doctor> getDoctorById(int id) async {
    try {
      final response = await dio.get("/doctors/$id");
      return Doctor.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to fetch doctor");
    }
  }
}