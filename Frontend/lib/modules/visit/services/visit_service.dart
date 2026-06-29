import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../model/visit.dart';

class VisitService {
  final Dio dio = ApiClient().dio;

  Future<Visit> checkIn({
    required int patientId,
    required int doctorId,
    required int appointmentId,
  }) async {
    final response = await dio.post(
      "/visits/checkin",
      data: {
        "patientId": patientId,
        "doctorId": doctorId,
        "appointmentId": appointmentId,
      },
    );

    return Visit.fromJson(response.data);
  }

  Future<Visit> getVisit(int id) async {
    final response = await dio.get(
      "/visits/$id",
    );

    return Visit.fromJson(response.data);
  }

  Future<Visit> getVisitByAppointment(int appointmentId) async {   // ADD THIS
    final response = await dio.get(
      "/visits/by-appointment/$appointmentId",
    );

    return Visit.fromJson(response.data);
  }
}