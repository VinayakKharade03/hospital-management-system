import 'package:flutter/material.dart';
import '../services/doctor_service.dart';
import '../models/doctor.dart';

class AddEditDoctorScreen extends StatefulWidget {
  final Doctor? doctor;

  const AddEditDoctorScreen({super.key, this.doctor});

  @override
  State<AddEditDoctorScreen> createState() => _AddEditDoctorScreenState();
}

class _AddEditDoctorScreenState extends State<AddEditDoctorScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final specializationController = TextEditingController();
  final feeController = TextEditingController();

  final DoctorService _service = DoctorService();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.doctor != null) {
      final d = widget.doctor!;

      firstNameController.text = d.firstName;
      lastNameController.text = d.lastName;
      emailController.text = d.email;
      phoneController.text = d.phone;
      specializationController.text = d.specialization;
      feeController.text = d.consultationFee.toString();
    }
  }

  // ✅ FIX: prevent memory leaks
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    specializationController.dispose();
    feeController.dispose();
    super.dispose();
  }

  Future<void> saveDoctor() async {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        specializationController.text.isEmpty ||
        feeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields required")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final data = {
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "specialization": specializationController.text.trim(),
        "consultationFee": double.parse(feeController.text),
      };

      if (widget.doctor == null) {
        await _service.createDoctor(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Doctor added")),
        );
      } else {
        await _service.updateDoctor(widget.doctor!.id, data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Doctor updated")),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doctor == null ? "Add Doctor" : "Edit Doctor"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: "First Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: "Last Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: specializationController,
              decoration: const InputDecoration(
                labelText: "Specialization",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: feeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Consultation Fee",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saveDoctor,
                child: Text(
                  widget.doctor == null ? "Add Doctor" : "Update Doctor",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}