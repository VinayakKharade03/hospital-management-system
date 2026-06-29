class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String role;
  final int userId;
  final Map<String, dynamic>? entity; // 🔥 ADD THIS

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.userId,
    this.entity,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    print("LOGIN RESPONSE => $json");

    return LoginResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      role: json['role'] ?? 'UNKNOWN',

      userId: (json['userId'] is int)
          ? json['userId']
          : int.tryParse(json['userId']?.toString() ?? '') ?? -1,

      // 🔥 THIS IS THE MISSING PIECE
      entity: json['entity'] != null
          ? Map<String, dynamic>.from(json['entity'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "role": role,
      "userId": userId,
      "entity": entity,
    };
  }
}