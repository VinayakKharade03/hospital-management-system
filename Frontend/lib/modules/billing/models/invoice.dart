class Invoice {
  final int id;
  final int visitId;
  final String patientName;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final String paymentStatus;
  final List<InvoiceItem> items;

  Invoice({
    required this.id,
    required this.visitId,
    required this.patientName,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    required this.paymentStatus,
    required this.items,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json["id"] ?? 0,
      visitId: json["visitId"] ?? 0,
      patientName: json["patientName"] ?? "",
      totalAmount: (json["totalAmount"] ?? 0).toDouble(),
      paidAmount: (json["paidAmount"] ?? 0).toDouble(),
      status: json["status"] ?? "",
      paymentStatus: json["paymentStatus"] ?? "",
      items: json["items"] == null
          ? []
          : (json["items"] as List)
          .map((e) => InvoiceItem.fromJson(e))
          .toList(),
    );
  }

  double get dueAmount => totalAmount - paidAmount;
}

class InvoiceItem {
  final String itemName;
  final int quantity;
  final double price;
  final double total;

  InvoiceItem({
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      itemName: json["itemName"] ?? "",
      quantity: json["quantity"] ?? 0,
      price: (json["price"] ?? 0).toDouble(),
      total: (json["total"] ?? 0).toDouble(),
    );
  }
}