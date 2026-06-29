class Medicine {
  final int id;
  final String name;
  final double? unitPrice;

  Medicine({required this.id, required this.name, this.unitPrice});

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'] ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
    );
  }

  @override
  String toString() => name;
}