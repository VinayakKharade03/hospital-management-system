import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/appointment.dart';

// Holds one page of results + whether more pages exist
class AppointmentPage {
  final List<Appointment> appointments;
  final bool hasMore;

  AppointmentPage({
    required this.appointments,
    required this.hasMore,
  });
}

class AppointmentService {

  final Dio dio = ApiClient().dio;

  // ================= GET ALL (paginated) =================

  Future<AppointmentPage> getAppointments({
    int page = 0,
    int size = 20,
    String sort = "appointmentTime,desc", // ✅ default: latest first
  }) async {

    final response = await dio.get(
      "/appointments",
      queryParameters: {
        "page": page,
        "size": size,
        "sort": sort, // ✅ Spring Pageable picks this up automatically
      },
    );

    final data = response.data;
    final List content = data['content'];

    // Spring Page response includes `last: true` on the final page
    final bool isLast = data['last'] ?? true;

    final appointments = content
        .map<Appointment>(
          (e) => Appointment.fromJson(e as Map<String, dynamic>),
    )
        .toList();

    return AppointmentPage(
      appointments: appointments,
      hasMore: !isLast,
    );
  }

  // ================= GET BY DOCTOR (paginated) =================

  Future<AppointmentPage> getAppointmentsByDoctor(
      int doctorId, {
        int page = 0,
        int size = 20,
        String sort = "appointmentTime,desc",
      }) async {

    final response = await dio.get(
      "/appointments/doctor/$doctorId",
      queryParameters: {
        "page": page,
        "size": size,
        "sort": sort,
      },
    );

    final data = response.data;

    // Support both: paginated Map response, or legacy flat List response
    if (data is Map) {
      final List content = data['content'] ?? [];
      final bool isLast = data['last'] ?? true;

      final appointments = content
          .map<Appointment>(
            (e) => Appointment.fromJson(e as Map<String, dynamic>),
      )
          .toList();

      return AppointmentPage(
        appointments: appointments,
        hasMore: !isLast,
      );
    } else {
      // Fallback: backend still returns a plain list (no pagination support yet)
      final List content = data as List;

      final appointments = content
          .map<Appointment>(
            (e) => Appointment.fromJson(e as Map<String, dynamic>),
      )
          .toList();

      return AppointmentPage(
        appointments: appointments,
        hasMore: false,
      );
    }
  }

  // ================= CREATE =================

  Future<void> createAppointment(
      Map<String, dynamic> data,
      ) async {

    await dio.post(
      "/appointments",
      data: data,
    );
  }

  // ================= UPDATE STATUS =================

  Future<void> updateAppointment(
      int id,
      Map<String, dynamic> data,
      ) async {

    await dio.patch(
      "/appointments/$id/status",
      data: data,
    );
  }

  // ================= DELETE =================

  Future<void> deleteAppointment(
      int id,
      ) async {

    await dio.delete(
      "/appointments/$id",
    );
  }

  // ================= BOOKED SLOTS =================

  Future<List<String>> getBookedSlots(
      int doctorId,
      String date,
      ) async {

    final response = await dio.get(
      "/appointments/booked",
      queryParameters: {
        "doctorId": doctorId,
        "date": date,
      },
    );

    return List<String>.from(response.data);
  }
}