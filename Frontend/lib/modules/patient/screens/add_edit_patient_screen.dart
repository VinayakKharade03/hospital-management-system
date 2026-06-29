import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/patient.dart';
import '../services/patient_service.dart';

class AddEditPatientScreen extends StatefulWidget {
  final Patient? patient;

  const AddEditPatientScreen({
    super.key,
    this.patient,
  });

  @override
  State<AddEditPatientScreen> createState() =>
      _AddEditPatientScreenState();
}

class _AddEditPatientScreenState
    extends State<AddEditPatientScreen> {

  final firstNameController =
  TextEditingController();

  final lastNameController =
  TextEditingController();

  final emailController =
  TextEditingController();

  final phoneController =
  TextEditingController();

  final addressController =
  TextEditingController();

  final PatientService _service =
  PatientService();

  DateTime? selectedDate;

  String selectedGender = "MALE";

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // PREFILL IF EDITING

    if (widget.patient != null) {
      final p = widget.patient!;

      firstNameController.text =
          p.firstName;

      lastNameController.text =
          p.lastName;

      emailController.text =
          p.email;

      phoneController.text =
          p.phone;

      selectedGender =
      p.gender.isNotEmpty
          ? p.gender
          : "MALE";
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,

      initialDate:
      DateTime(2000),

      firstDate:
      DateTime(1900),

      lastDate:
      DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> savePatient() async {

    // VALIDATION

    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        selectedDate == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all required fields",
          ),
        ),
      );

      return;
    }

    // PHONE VALIDATION

    final phone =
    phoneController.text.trim();

    final phoneRegex =
    RegExp(r'^[6-9]\d{9}$');

    if (!phoneRegex.hasMatch(phone)) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Enter valid Indian phone number",
          ),
        ),
      );

      return;
    }

    try {

      setState(() {
        isLoading = true;
      });

      final data = {

        "firstName":
        firstNameController.text.trim(),

        "lastName":
        lastNameController.text.trim(),

        "email":
        emailController.text.trim(),

        "phone":
        phone,

        "dateOfBirth":
        selectedDate!
            .toIso8601String()
            .split('T')[0],

        "gender":
        selectedGender,

        "address":
        addressController.text.trim(),
      };

      if (widget.patient == null) {

        await _service.createPatient(
          data,
        );

      } else {

        await _service.updatePatient(
          widget.patient!.id!,
          data,
        );
      }

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              widget.patient == null
                  ? "Patient Added"
                  : "Patient Updated",
            ),
          ),
        );

        Navigator.pop(context, true);
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(
          widget.patient == null
              ? "Add Patient"
              : "Edit Patient",
        ),
      ),

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(20),

        child: Column(
          children: [

            // FIRST NAME

            TextField(
              controller:
              firstNameController,

              decoration:
              const InputDecoration(
                labelText:
                "First Name *",

                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // LAST NAME

            TextField(
              controller:
              lastNameController,

              decoration:
              const InputDecoration(
                labelText:
                "Last Name *",

                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // EMAIL

            TextField(
              controller:
              emailController,

              decoration:
              const InputDecoration(
                labelText: "Email",

                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // PHONE

            TextField(
              controller:
              phoneController,

              keyboardType:
              TextInputType.phone,

              maxLength: 10,

              decoration:
              const InputDecoration(
                labelText:
                "Phone *",

                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // DATE OF BIRTH

            InkWell(
              onTap: pickDate,

              child: InputDecorator(

                decoration:
                const InputDecoration(
                  labelText:
                  "Date Of Birth *",

                  border:
                  OutlineInputBorder(),
                ),

                child: Text(
                  selectedDate == null
                      ? "Select Date"

                      : DateFormat(
                    'yyyy-MM-dd',
                  ).format(
                    selectedDate!,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // GENDER

            DropdownButtonFormField<String>(

              value: selectedGender,

              decoration:
              const InputDecoration(
                labelText: "Gender",

                border:
                OutlineInputBorder(),
              ),

              items: const [

                DropdownMenuItem(
                  value: "MALE",
                  child: Text("MALE"),
                ),

                DropdownMenuItem(
                  value: "FEMALE",
                  child: Text("FEMALE"),
                ),

                DropdownMenuItem(
                  value: "OTHER",
                  child: Text("OTHER"),
                ),
              ],

              onChanged: (value) {

                if (value != null) {
                  setState(() {
                    selectedGender = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // ADDRESS

            TextField(
              controller:
              addressController,

              maxLines: 3,

              decoration:
              const InputDecoration(
                labelText: "Address",

                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 28),

            // BUTTON

            isLoading

                ? const CircularProgressIndicator()

                : SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(

                onPressed:
                savePatient,

                child: Text(
                  widget.patient == null

                      ? "Add Patient"

                      : "Update Patient",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}