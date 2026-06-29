class Visit {
  final int? id;
  final int patientId;
  final int doctorId;
  final int appointmentId;
  final String? status;

  Visit({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentId,
    this.status,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: (json['id'] ?? json['visitId']) as int?,
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      appointmentId: json['appointmentId'],
      status: json['status'],
    );
  }
}