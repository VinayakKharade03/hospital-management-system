import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/availability.dart';

class DoctorAvailabilityService {

  final Dio dio = ApiClient().dio;

  Future<List<Availability>> getAvailability(
      int doctorId,
      ) async {

    final response = await dio.get(
      "/doctors/$doctorId/availability",
    );

    return (response.data as List)
        .map(
          (e) => Availability.fromJson(e),
    )
        .toList();
  }
}