class DoctorProfile {

  final int id;

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String specialization;
  final double consultationFee;

  DoctorProfile({
    required this.id,

    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.consultationFee,
  });

  // ✅ ENTITY PARSER
  factory DoctorProfile.fromJson(
      Map<String, dynamic> json,
      ) {
    return DoctorProfile(

      id: json['id'] ?? 0,

      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone']?.toString() ?? '',
      specialization:
      json['specialization'] ?? '',

      consultationFee:
      (json['consultationFee'] ?? 0)
          .toDouble(),
    );
  }

  // ✅ LOGIN RESPONSE PARSER
  factory DoctorProfile.fromLoginResponse(
      Map<String, dynamic> json,
      ) {
    final entity = json['entity'];

    return DoctorProfile(

      id: entity?['id'] ?? 0,

      firstName: entity?['firstName'] ?? '',
      lastName: entity?['lastName'] ?? '',
      email: entity?['email'] ?? '',
      phone: entity?['phone']?.toString() ?? '',
      specialization:
      entity?['specialization'] ?? '',

      consultationFee:
      (entity?['consultationFee'] ?? 0)
          .toDouble(),
    );
  }

  String get fullName =>
      "$firstName $lastName";

  // ✅ OPTIONAL JSON EXPORT
  Map<String, dynamic> toJson() {
    return {

      "id": id,

      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phone": phone,
      "specialization": specialization,
      "consultationFee": consultationFee,
    };
  }
}