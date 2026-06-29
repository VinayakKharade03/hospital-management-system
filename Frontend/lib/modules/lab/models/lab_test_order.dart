// lib/modules/lab/model/lab_test_order.dart

class LabTestOrder {
  final int id;
  final String patientName;
  final String doctorName;
  final String testName;
  final String status;
  final DateTime? orderedAt;

  LabTestOrder({
    required this.id,
    required this.patientName,
    required this.doctorName,
    required this.testName,
    required this.status,
    this.orderedAt,
  });

  factory LabTestOrder.fromJson(
      Map<String, dynamic> json,
      ) {
    return LabTestOrder(
      id: json["id"] ?? 0,
      patientName: json["patientName"] ?? "",
      doctorName: json["doctorName"] ?? "",
      testName: json["testName"] ?? "",
      status: json["status"] ?? "",
      orderedAt: json["orderedAt"] != null
          ? DateTime.tryParse(json["orderedAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "patientName": patientName,
      "doctorName": doctorName,
      "testName": testName,
      "status": status,
      "orderedAt": orderedAt?.toIso8601String(),
    };
  }
}