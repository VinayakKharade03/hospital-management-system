import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/login_response.dart';

class AuthService {
  final Dio dio = ApiClient().dio;

  // ================= LOGIN =================
  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await dio.post(
        "/auth/login",
        data: {
          "username": username,
          "password": password,
        },
      );

      print("LOGIN RAW RESPONSE => ${response.data}");

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      print("LOGIN ERROR => ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  // ================= REGISTER =================
  Future<void> register(
      String username,
      String password,
      String role,
      ) async {
    try {
      await dio.post(
        "/auth/register",
        data: {
          "username": username,
          "password": password,
          "role": role,
        },
      );
    } on DioException catch (e) {
      print("REGISTER ERROR => ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  // ================= REFRESH =================
  // ================= REFRESH =================
  Future<LoginResponse> refresh(String refreshToken) async {
    try {
      final response = await dio.post(
        "/auth/refresh",
        data: {
          "refreshToken": refreshToken,
        },
      );

      print("REFRESH RAW RESPONSE => ${response.data}");

      // 🟢 THE FIX: Safely access response data since Dio has already parsed it into a Map
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;

      // Ensure refresh token is preserved
      data["refreshToken"] = refreshToken;

      return LoginResponse.fromJson(data);
    } on DioException catch (e) {
      print("REFRESH ERROR => ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout(String refreshToken) async {
    try {
      await dio.post(
        "/auth/logout",
        data: {
          "refreshToken": refreshToken,
        },
      );
    } on DioException catch (e) {
      print("LOGOUT ERROR => ${e.response?.data ?? e.message}");
    }
  }
}