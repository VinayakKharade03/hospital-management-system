class Doctor {
  final int id;
  final int? userId;
  final String firstName;
  final String lastName;
  final String email;
  final String specialization;
  final double consultationFee;
  final String phone;

  Doctor({
    required this.id,
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.specialization,
    required this.consultationFee,
    required this.phone,
  });

  // ✅ ADD THIS (fixes your error)
  String get fullName => "$firstName $lastName";

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      specialization: json['specialization'],
      consultationFee: (json['consultationFee'] as num).toDouble(),
      phone: json['phone'],
      userId: json['userId'], // optional safe mapping
    );
  }
}