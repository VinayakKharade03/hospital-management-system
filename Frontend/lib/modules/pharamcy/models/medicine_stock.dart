class MedicineStock {
  final int id;
  final String medicineName;
  final int quantity;
  final String batchNumber;
  final DateTime? mfgDate;
  final DateTime? expiryDate;

  MedicineStock({
    required this.id,
    required this.medicineName,
    required this.quantity,
    required this.batchNumber,
    this.mfgDate,
    this.expiryDate,
  });

  factory MedicineStock.fromJson(Map<String, dynamic> json) {
    return MedicineStock(
      id: json['id'] ?? 0,
      medicineName: json['medicineName'] ?? '',
      quantity: json['quantity'] ?? 0,
      batchNumber: json['batchNumber'] ?? '',
      mfgDate:
      json['mfgDate'] != null ? DateTime.tryParse(json['mfgDate']) : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'])
          : null,
    );
  }
}