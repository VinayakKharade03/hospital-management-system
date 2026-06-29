// lib/modules/pharamcy/screens/dispense_medicine_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medicine.dart';
import '../providers/pharmacy_provider.dart';

class DispenseMedicineScreen extends StatefulWidget {
  final Medicine medicine;

  const DispenseMedicineScreen({super.key, required this.medicine});

  @override
  State<DispenseMedicineScreen> createState() => _DispenseMedicineScreenState();
}

class _DispenseMedicineScreenState extends State<DispenseMedicineScreen> {
  final visitIdController = TextEditingController();
  final quantityController = TextEditingController();

  @override
  void dispose() {
    visitIdController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final visitId = int.tryParse(visitIdController.text.trim());
    final qty = int.tryParse(quantityController.text.trim());

    if (visitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid Visit ID")),
      );
      return;
    }
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid quantity")),
      );
      return;
    }

    final pharmacy = Provider.of<PharmacyProvider>(context, listen: false);

    final success = await pharmacy.dispense(
      visitId: visitId,
      medicineId: widget.medicine.id,
      quantity: qty,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medicine dispensed successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to dispense. Check stock availability.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pharmacy = Provider.of<PharmacyProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Dispense — ${widget.medicine.name}")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: visitIdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Visit ID",
              hintText: "Enter the patient visit ID",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.event_note_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Quantity",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.medication_outlined),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: pharmacy.isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
              child: pharmacy.isSubmitting
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text("Dispense Medicine"),
            ),
          ),
        ],
      ),
    );
  }
}