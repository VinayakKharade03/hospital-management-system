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

  // ================= GET BY DOCTOR =================

  Future<List<Appointment>> getAppointmentsByDoctor(
      int doctorId,
      ) async {

    final response = await dio.get(
      "/appointments/doctor/$doctorId",
    );

    final data = response.data;

    final List content =
    data is Map ? data['content'] : data;

    return content
        .map<Appointment>(
          (e) => Appointment.fromJson(e as Map<String, dynamic>),
    )
        .toList();
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