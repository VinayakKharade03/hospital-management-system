// lib/modules/pharamcy/screens/add_stock_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medicine.dart';
import '../providers/pharmacy_provider.dart';

class AddStockScreen extends StatefulWidget {
  final Medicine medicine;

  const AddStockScreen({super.key, required this.medicine});

  @override
  State<AddStockScreen> createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen> {
  final quantityController = TextEditingController();
  final batchController = TextEditingController();
  final supplierController = TextEditingController();

  DateTime? mfgDate;
  DateTime? expiryDate;

  @override
  void dispose() {
    quantityController.dispose();
    batchController.dispose();
    supplierController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isMfg}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        if (isMfg) {
          mfgDate = picked;
        } else {
          expiryDate = picked;
        }
      });
    }
  }

  String _fmt(DateTime? d) =>
      d == null ? "Select date" : "${d.day}/${d.month}/${d.year}";

  Future<void> _submit() async {
    final qty = int.tryParse(quantityController.text.trim());

    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid quantity")),
      );
      return;
    }
    if (batchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter batch number")),
      );
      return;
    }
    if (mfgDate == null || expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select manufacturing and expiry dates")),
      );
      return;
    }

    final pharmacy = Provider.of<PharmacyProvider>(context, listen: false);

    final success = await pharmacy.addStock(
      medicineId: widget.medicine.id,
      quantity: qty,
      batchNumber: batchController.text.trim(),
      mfgDate: mfgDate!,
      expiryDate: expiryDate!,
      supplier: supplierController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stock added")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add stock")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pharmacy = Provider.of<PharmacyProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Add Stock — ${widget.medicine.name}")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Quantity",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: batchController,
            decoration: const InputDecoration(
              labelText: "Batch number",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: supplierController,
            decoration: const InputDecoration(
              labelText: "Supplier",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(isMfg: true),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text("Mfg: ${_fmt(mfgDate)}"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(isMfg: false),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text("Exp: ${_fmt(expiryDate)}"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: pharmacy.isSubmitting ? null : _submit,
              child: pharmacy.isSubmitting
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text("Add Stock"),
            ),
          ),
        ],
      ),
    );
  }
}