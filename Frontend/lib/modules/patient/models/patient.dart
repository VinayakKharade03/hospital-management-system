class Patient {

  final int id;

  final String firstName;
  final String lastName;

  final String phone;
  final String email;

  final String dateOfBirth;

  final String gender;
  final String address;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
  });

  factory Patient.fromJson(
      Map<String, dynamic> json,
      ) {

    return Patient(

      id: json['id'],

      firstName:
      json['firstName'] ?? '',

      lastName:
      json['lastName'] ?? '',

      phone:
      json['phone'] ?? '',

      email:
      json['email'] ?? '',

      dateOfBirth:
      json['dateOfBirth'] ?? '',

      gender:
      json['gender'] ?? '',

      address:
      json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {

    return {

      "firstName": firstName,

      "lastName": lastName,

      "phone": phone,

      "email": email,

      "dateOfBirth": dateOfBirth,

      "gender": gender,

      "address": address,
    };
  }

  String get fullName =>
      "$firstName $lastName";
}