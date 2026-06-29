import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user_role.dart';
import '../../doctor/models/DoctorProfile.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? token;
  int? userId;
  UserRole role = UserRole.UNKNOWN;
  DoctorProfile? doctor;

  // ✅ Keep true initially so the RootScreen spinner shows on boot up
  bool isLoading = true;

  bool get isAuthenticated => token != null;
  bool get isDoctor => role == UserRole.DOCTOR;
  int? get doctorId => doctor?.id;

  // ================= LOGIN =================
  Future<void> login(String username, String password) async {
    try {
      isLoading = true;
      notifyListeners();
      print("🔵 [LOGIN] Starting...");

      final response = await _authService.login(username, password);
      print("🔵 [LOGIN] Response received");

      token = response.accessToken;
      userId = response.userId;
      role = parseRole(response.role);

      print("🟢 [LOGIN] Token set: ${token?.substring(0, 20)}...");
      print("🟢 [LOGIN] Role: $role");

      await SecureStorage.saveTokens(
        response.accessToken,
        response.refreshToken,
        roleToString(role),
        response.userId,
      );
      print("🟢 [LOGIN] Saved to storage");

      if (role == UserRole.DOCTOR && response.entity != null) {
        final Map<String, dynamic> doctorMap = Map<String, dynamic>.from(response.entity as Map);
        doctor = DoctorProfile.fromJson(doctorMap);
        await SecureStorage.saveDoctor(doctorMap);
      } else {
        doctor = null;
        await SecureStorage.saveDoctor(null);
      }

    } catch (e) {
      print("🔴 [LOGIN ERROR] $e");
      token = null;
      userId = null;
      role = UserRole.UNKNOWN;
      rethrow;
    } finally {
      isLoading = false;
      print("🟠 [LOGIN] Calling notifyListeners()");
      notifyListeners();
      print("✅ [LOGIN] notifyListeners() done");
    }
  }
  // ================= CREATE USER =================
  Future<void> createUser(String username, String password, String role) async {
    try {
      isLoading = true;
      notifyListeners();

      await _authService.register(username, password, role);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================= AUTO LOGIN =================
  Future<void> tryAutoLogin() async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();

      if (refreshToken == null) {
        isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _authService.refresh(refreshToken);

      token = response.accessToken;
      userId = response.userId;
      role = parseRole(response.role);

      await SecureStorage.saveTokens(
        response.accessToken,
        refreshToken,
        roleToString(role),
        response.userId,
      );

      // 🟢 THE FIX: Only attempt recovery if the user role is actually a doctor
      if (role == UserRole.DOCTOR) {
        final storedDoctor = await SecureStorage.getDoctor();
        doctor = storedDoctor != null
            ? DoctorProfile.fromJson(storedDoctor)
            : null;
      } else {
        doctor = null;
      }

    } catch (e) {
      print("Auto-login failed sequence caught: $e");
      await logout();
    }

    isLoading = false;
    notifyListeners();
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken != null) {
        await _authService.logout(refreshToken);
      }
    } catch (_) {}

    token = null;
    userId = null;
    role = UserRole.UNKNOWN;
    doctor = null;

    await SecureStorage.clear();

    isLoading = false;
    notifyListeners();
  }
}