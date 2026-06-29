// lib/modules/prescription/models/prescription_response.dart

class PrescriptionResponse {
  final int id;
  final int visitId;
  final int? doctorId;
  final String? doctorName;
  final String? patientName;
  final List<PrescriptionItem> items;
  final bool isDispensed;

  PrescriptionResponse({
    required this.id,
    required this.visitId,
    this.doctorId,
    this.doctorName,
    this.patientName,
    required this.items,
    this.isDispensed = false,
  });

  factory PrescriptionResponse.fromJson(Map<String, dynamic> json) {
    return PrescriptionResponse(
      id: json['id'] ?? 0,
      visitId: json['visitId'] ?? 0,
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      patientName: json['patientName'],
      isDispensed: json['isDispensed'] ?? false,
      items: (json['items'] as List?)
          ?.map((item) => PrescriptionItem.fromJson(item))
          .toList() ?? [],
    );
  }
}

class PrescriptionItem {
  final int medicineId;
  final String medicineName;
  final int prescribedQuantity;   // was: quantity
  final int dispensedQuantity;    // NEW
  final String? instructions;


  PrescriptionItem({
    required this.medicineId,
    required this.medicineName,
    required this.prescribedQuantity,
    this.dispensedQuantity = 0,
    this.instructions,
  });


  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      medicineId: json['medicineId'] ?? 0,
      medicineName: json['medicineName'] ?? '',
      prescribedQuantity: json['prescribedQuantity'] ?? 0,
      dispensedQuantity: json['dispensedQuantity'] ?? 0,
      instructions: json['instructions'],
    );
  }
}