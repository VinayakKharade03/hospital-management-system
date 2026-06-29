import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  // ================= SAVE TOKENS =================
  static Future<void> saveTokens(
      String accessToken,
      String refreshToken,
      String role,
      int? userId,
      ) async {
    await _storage.write(key: "accessToken", value: accessToken);

    await _storage.write(
      key: "refreshToken",
      value: refreshToken,
    );

    await _storage.write(
      key: "role",
      value: role,
    );

    if (userId != null) {
      await _storage.write(
        key: "userId",
        value: userId.toString(),
      );
    }
  }

  // ================= SAVE ACCESS TOKEN =================
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(
      key: "accessToken",
      value: token,
    );
  }

  // ================= SAVE USER ID =================
  static Future<void> saveUserId(int userId) async {
    await _storage.write(
      key: "userId",
      value: userId.toString(),
    );
  }

  // ================= GET ACCESS TOKEN =================
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: "accessToken");
  }

  // ================= GET REFRESH TOKEN =================
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: "refreshToken");
  }

  // ================= GET ROLE =================
  static Future<String?> getRole() async {
    return await _storage.read(key: "role");
  }

  // ================= GET USER ID =================
  static Future<int?> getUserId() async {
    final value = await _storage.read(key: "userId");

    if (value == null) return null;

    return int.tryParse(value);
  }

  // ================= DOCTOR PROFILE CACHE =================

  static Future<void> saveDoctor(
      Map<String, dynamic>? doctor,
      ) async {
    if (doctor == null) {
      await _storage.delete(key: "doctor");
      return;
    }

    await _storage.write(
      key: "doctor",
      value: jsonEncode(doctor),
    );
  }

  static Future<Map<String, dynamic>?> getDoctor() async {
    final data = await _storage.read(key: "doctor");

    if (data == null) return null;

    return jsonDecode(data);
  }

  // ================= CLEAR =================
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}