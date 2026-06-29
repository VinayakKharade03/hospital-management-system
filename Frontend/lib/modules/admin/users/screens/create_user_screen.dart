import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  String role = "DOCTOR";

  void createUser() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    try {
      await auth.createUser(
        usernameController.text,
        passwordController.text,
        role,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User created successfully")),
      );

      usernameController.clear();
      passwordController.clear();
      setState(() => role = "DOCTOR");

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create User"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // 🔹 Username
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // 🔹 Password
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // 🔹 Role Dropdown (FULL WIDTH)
            DropdownButtonFormField<String>(
              value: role,
              decoration: const InputDecoration(
                labelText: "Select Role",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() => role = val!);
              },
              items: const [

                DropdownMenuItem(
                  value: "DOCTOR",
                  child: Text("DOCTOR"),
                ),

                DropdownMenuItem(
                  value: "RECEPTIONIST",
                  child: Text("RECEPTIONIST"),
                ),

                DropdownMenuItem(
                  value: "LAB_TECHNICIAN",
                  child: Text("LAB TECHNICIAN"),
                ),

                DropdownMenuItem(
                  value: "PHARMACIST",
                  child: Text("PHARMACIST"),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 🔹 Create Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: auth.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: createUser,
                child: const Text(
                  "Create User",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}