import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'modules/auth/providers/auth_provider.dart';
import 'modules/auth/screens/auth_screen.dart';
import 'modules/admin/screens/dashboard_screen.dart';
import 'modules/doctor/screens/doctor_dashboard_screen.dart';
import 'modules/receptionist/screens/receptionist_dashboard_screen.dart';
import 'modules/auth/models/user_role.dart';
import 'modules/lab/screens/lab_technician_screen.dart';
import 'modules/lab/providers/lab_provider.dart';
import 'modules/pharamcy/screens/pharmacy_home_screen.dart';
import 'modules/pharamcy/providers/pharmacy_provider.dart'; // 🟢 Added import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LabProvider()),
        ChangeNotifierProvider(create: (_) => PharmacyProvider()), // 🟢 Registered globally here
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RootScreen(),
      ),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  // 🟢 Local flag to track if the boot check has run at least once
  bool _hasCheckedAutoLogin = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  // 🟢 CLEAN SEQUENCE: Runs your initialization deterministically
  Future<void> _initAuth() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.tryAutoLogin();
    if (mounted) {
      setState(() {
        _hasCheckedAutoLogin = true; // Breaks the initial frame trap
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("🟣🟣🟣 RootScreen.build() CALLED 🟣🟣🟣");
    final auth = Provider.of<AuthProvider>(context);

    // 🔄 1. BOOTSTRAP CONTROL — ONLY block the full screen during the initial morning app boot check
    if (!_hasCheckedAutoLogin) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF18864B),
          ),
        ),
      );
    }

    // ✅ 2. AUTHENTICATED PANEL — Check token directly. It doesn't matter if isLoading is true or false!
    if (auth.token != null && auth.token!.isNotEmpty) {
      switch (auth.role) {
        case UserRole.ADMIN:
          return const DashboardScreen();
        case UserRole.DOCTOR:
          return const DoctorDashboardScreen();
        case UserRole.RECEPTIONIST:
          return const ReceptionistDashboardScreen();
        case UserRole.LAB_TECHNICIAN:
          return const LabTechnicianScreen();
        case UserRole.PHARMACIST:
          return const PharmacyHomeScreen();
        default:
          return const Scaffold(
            body: Center(child: Text("Unauthorized Role")),
          );
      }
    }

    // 🔐 3. NOT LOGGED IN — Let AuthScreen handle its own button-level spinner internally
    return const AuthScreen();
  }
}