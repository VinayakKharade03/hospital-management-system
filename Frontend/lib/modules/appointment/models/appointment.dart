class Appointment {

  final int id;

  final int patientId;
  final int doctorId;

  final String patientName;
  final String doctorName;

  final String appointmentTime;

  final String status;

  final bool checkedIn;

  final int? queueNumber;

  final String? notes;

  final String? doctorSpecialization;

  final double? consultationFee;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    required this.appointmentTime,
    required this.status,
    required this.checkedIn,
    this.queueNumber,
    this.notes,
    this.doctorSpecialization,
    this.consultationFee,
  });

  factory Appointment.fromJson(
      Map<String, dynamic> json,
      ) {

    return Appointment(

      id: json['id'],

      patientId: json['patientId'],

      doctorId: json['doctorId'],

      patientName:
      json['patientName'] ?? '',

      doctorName:
      json['doctorName'] ?? '',

      appointmentTime:
      json['appointmentTime'] ?? '',

      status:
      json['status'] ?? '',

      checkedIn:
      json['checkedIn'] ?? false,

      queueNumber:
      json['queueNumber'],

      notes:
      json['notes'],

      doctorSpecialization:
      json['doctorSpecialization'],

      consultationFee:
      json['consultationFee'] != null
          ? (json['consultationFee'] as num)
          .toDouble()
          : null,
    );
  }

  // ✅ Returns a copy of this appointment with the given fields replaced.
  // Any field not passed in keeps its current value.
  Appointment copyWith({
    int? id,
    int? patientId,
    int? doctorId,
    String? patientName,
    String? doctorName,
    String? appointmentTime,
    String? status,
    bool? checkedIn,
    int? queueNumber,
    String? notes,
    String? doctorSpecialization,
    double? consultationFee,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
      checkedIn: checkedIn ?? this.checkedIn,
      queueNumber: queueNumber ?? this.queueNumber,
      notes: notes ?? this.notes,
      doctorSpecialization:
      doctorSpecialization ?? this.doctorSpecialization,
      consultationFee: consultationFee ?? this.consultationFee,
    );
  }
}