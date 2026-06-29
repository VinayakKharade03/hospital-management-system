import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 🟢 Added for state lookups
import '../../visit/model/visit.dart';
import '../service/prescription_service.dart';
import '../../pharamcy/models/medicine.dart';
import '../../pharamcy/service/medicine_service.dart';

// 🟢 CRITICAL: Import your AuthProvider file to fetch the doctor's active session token
// (Adjust this relative path if your AuthProvider is nested elsewhere)
import '../../auth/providers/auth_provider.dart';

class WritePrescriptionScreen extends StatefulWidget {
  final Visit visit;

  const WritePrescriptionScreen({super.key, required this.visit});

  @override
  State<WritePrescriptionScreen> createState() => _WritePrescriptionScreenState();
}

class _WritePrescriptionScreenState extends State<WritePrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();

  final PrescriptionService _prescriptionService = PrescriptionService();
  final MedicineService _medicineService = MedicineService();

  List<Map<String, dynamic>> medicines = [
    {
      "medicineId": null,
      "medicineName": "",
      "dosage": "",
      "frequency": "",
      "duration": ""
    }
  ];

  bool isSaving = false;

  Future<void> savePrescription() async {
    if (!_formKey.currentState!.validate()) return;

    final missingMedicine = medicines.any((m) => m["medicineId"] == null);
    if (missingMedicine) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a valid medicine from the list for every row.")),
      );
      return;
    }

    // 🟢 Step 1: Extract the authorization token safely before switching the screen loading state
    final token = Provider.of<AuthProvider>(context, listen: false).token ?? '';

    setState(() => isSaving = true);
    try {
      final payloadItems = medicines.map((m) {
        // Safely extract and parse the dosage string into an integer.
        // If it's empty or cannot be parsed, fallback to 0.
        final parsedQuantity = int.tryParse(m["dosage"] ?? "") ?? 0;

        return {
          "medicineId": m["medicineId"],
          "dosage": m["dosage"],
          "frequency": m["frequency"],
          "duration": m["duration"],
          "prescribedQuantity": parsedQuantity, // 🌟 Sends parsed integer to the backend
        };
      }).toList();

      // 🟢 Step 2: Pass the token argument down to your backend payload service container
      await _prescriptionService.createPrescription(
        visitId: widget.visit.id ?? 0,
        items: payloadItems,
        notes: _notesController.text,
        token: token, // ✨ Fixed compilation error
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Prescription saved successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save prescription: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prescription for Visit #${widget.visit.id ?? '-'}"),
      ),
      body: isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              "Patient ID: ${widget.visit.patientId ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "Medicines",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            const Divider(),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Autocomplete<Medicine>(
                          initialValue: TextEditingValue(
                            text: medicines[index]["medicineName"] ?? "",
                          ),
                          displayStringForOption: (Medicine m) => m.name,
                          optionsBuilder: (TextEditingValue textValue) async {
                            if (textValue.text.trim().isEmpty) {
                              return const Iterable<Medicine>.empty();
                            }
                            try {
                              final results = await _medicineService.searchMedicines(textValue.text);
                              debugPrint("Autocomplete results: ${results.length}");
                              return results;
                            } catch (e, stack) {
                              debugPrint("Autocomplete error: $e");
                              debugPrint("Stack trace:\n$stack");
                              return const Iterable<Medicine>.empty();
                            }
                          },
                          onSelected: (Medicine selected) {
                            setState(() {
                              medicines[index]["medicineId"] = selected.id;
                              medicines[index]["medicineName"] = selected.name;
                            });
                          },
                          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(labelText: "Medicine Name"),
                              validator: (v) =>
                              v == null || v.isEmpty ? "Enter medicine name" : null,
                              onChanged: (v) {
                                medicines[index]["medicineName"] = v;
                              },
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                child: SizedBox(
                                  width: 300,
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, i) {
                                      final option = options.elementAt(i);
                                      return ListTile(
                                        title: Text(option.name),
                                        subtitle: option.unitPrice != null
                                            ? Text("₹${option.unitPrice}")
                                            : null,
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: "Dosage (e.g., 1 tablet)"),
                                validator: (v) => v == null || v.isEmpty ? "Enter dosage" : null,
                                onChanged: (v) => medicines[index]["dosage"] = v,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: "Frequency (e.g., 1-0-1)"),
                                validator: (v) => v == null || v.isEmpty ? "Enter frequency" : null,
                                onChanged: (v) => medicines[index]["frequency"] = v,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: "Duration (e.g., 5 days)"),
                                validator: (v) => v == null || v.isEmpty ? "Enter duration" : null,
                                onChanged: (v) => medicines[index]["duration"] = v,
                              ),
                            ),
                          ],
                        ),
                        if (medicines.length > 1)
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => medicines.removeAt(index));
                              },
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),

            TextButton.icon(
              onPressed: () {
                setState(() {
                  medicines.add({
                    "medicineId": null,
                    "medicineName": "",
                    "dosage": "",
                    "frequency": "",
                    "duration": ""
                  });
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Another Medicine"),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Doctor Notes / Instructions",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: savePrescription,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Save & Sync Billing", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}