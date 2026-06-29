import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      await auth.login(
        usernameController.text,
        passwordController.text,
      );

      // ✅ FIX: prevent crash if widget disposed
      if (!mounted) return;

      // ❌ No navigation (RootScreen handles it)

    } catch (e) {
      // ✅ FIX: safe context usage
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    final isDesktop =
        MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Container(
            width: isDesktop ? 500 : double.infinity,

            padding: const EdgeInsets.all(32),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // =====================================
                // LOGO
                // =====================================

                Container(
                  width: 90,
                  height: 90,

                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7EF),
                    borderRadius:
                    BorderRadius.circular(45),
                  ),

                  child: const Icon(
                    Icons.local_hospital,
                    size: 42,
                    color: Color(0xFF18864B),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "CareConnect Hospital",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Employee Login",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 40),

                // =====================================
                // USERNAME
                // =====================================

                TextField(
                  controller: usernameController,

                  decoration: InputDecoration(
                    labelText: "Username",

                    prefixIcon: const Icon(
                      Icons.person_outline,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // =====================================
                // PASSWORD
                // =====================================

                TextField(
                  controller: passwordController,
                  obscureText: true,

                  decoration: InputDecoration(
                    labelText: "Password",

                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                auth.isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  height: 56,

                  child: ElevatedButton.icon(
                    onPressed: login,

                    icon: const Icon(
                      Icons.login,
                    ),

                    label: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(
                        0xFF18864B,
                      ),

                      foregroundColor:
                      Colors.white,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Divider(
                  color: Colors.grey.shade300,
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    Icon(
                      Icons.security,
                      size: 18,
                      color: Colors.grey.shade700,
                    ),

                    const SizedBox(width: 8),

                    Text(
                      "Authorized Personnel Only",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }}