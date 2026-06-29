import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/patient.dart';

class PatientService {
  final Dio dio = ApiClient().dio;

  // ✅ FIXED (handles Spring Boot Page response)
  Future<List<Patient>> getPatients() async {
    final response = await dio.get("/patients?page=0&size=20");

    final List content = response.data['content'];

    return content
        .map((e) => Patient.fromJson(e))
        .toList();
  }

  Future<void> createPatient(Map<String, dynamic> data) async {
    await dio.post("/patients", data: data);
  }

  Future<void> updatePatient(int id, Map<String, dynamic> data) async {
    await dio.put("/patients/$id", data: data);
  }

  Future<void> deletePatient(int id) async {
    await dio.delete("/patients/$id");
  }
}