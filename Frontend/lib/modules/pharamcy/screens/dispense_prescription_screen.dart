// lib/modules/pharamcy/screens/dispense_prescription_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pharmacy_provider.dart';
import '../../prescription/models/PrescriptionResponse.dart';

// 🟢 CRITICAL: Import your app's AuthProvider to read the logged-in user's token
import '../../auth/providers/auth_provider.dart';

class DispensePrescriptionScreen extends StatefulWidget {
  const DispensePrescriptionScreen({super.key});

  @override
  State<DispensePrescriptionScreen> createState() => _DispensePrescriptionScreenState();
}

class _DispensePrescriptionScreenState extends State<DispensePrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _visitSearchController = TextEditingController();

  // 🟢 Track pharmacist inputs by pairing the medicineId to the target dispense amount
  final Map<int, int> _dispenseAmounts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token ?? '';
      Provider.of<PharmacyProvider>(context, listen: false).fetchPendingQueue(token);
    });
  }

  @override
  void dispose() {
    _visitSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pharmacy = Provider.of<PharmacyProvider>(context);
    final token = Provider.of<AuthProvider>(context, listen: false).token ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dispense Core Prescriptions"),
        leading: pharmacy.searchedPrescription != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              pharmacy.searchedPrescription = null;
              _dispenseAmounts.clear(); // Clear local state on back
            });
          },
        )
            : null,
      ),
      body: Column(
        children: [
          // Visit ID Search Box Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _visitSearchController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter Patient Visit ID...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () {
                    final idStr = _visitSearchController.text.trim();
                    if (idStr.isNotEmpty) {
                      pharmacy.searchPrescriptionByVisit(int.parse(idStr), token);
                    }
                  },
                  child: const Text("Lookup"),
                ),
              ],
            ),
          ),

          // Dedicated Prescription Error Notification Banner
          if (pharmacy.prescriptionError != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      pharmacy.prescriptionError!,
                      style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.red),
                    onPressed: () => pharmacy.fetchPendingQueue(token),
                  )
                ],
              ),
            ),

          // Display content layout split
          Expanded(
            child: pharmacy.isPrescriptionLoading
                ? const Center(child: CircularProgressIndicator())
                : pharmacy.searchedPrescription != null
                ? Form(
              key: _formKey,
              child: _prescriptionDetailView(pharmacy.searchedPrescription!, pharmacy, token),
            )
                : _queueListView(pharmacy),
          ),
        ],
      ),
    );
  }

  Widget _queueListView(PharmacyProvider pharmacy) {
    if (pharmacy.pendingPrescriptions.isEmpty) {
      return const Center(child: Text("No pending doctor prescriptions in the queue."));
    }

    // Sort by visitId descending — highest (newest) first
    final sorted = [...pharmacy.pendingPrescriptions]
      ..sort((a, b) => b.visitId.compareTo(a.visitId));

    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final rx = sorted[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.assignment)),
            title: Text("Visit ID: ${rx.visitId} — ${rx.patientName ?? 'Unknown Patient'}"),
            subtitle: Text("Prescribed by: ${rx.doctorName ?? 'Staff Doctor'}\nItems Count: ${rx.items.length}"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              setState(() {
                pharmacy.searchedPrescription = rx;
              });
            },
          ),
        );
      },
    );
  }

  Widget _prescriptionDetailView(PrescriptionResponse rx, PharmacyProvider provider, String token) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.account_circle, size: 40, color: Colors.blue),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Patient: ${rx.patientName ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Visit Ticket Reference: #${rx.visitId}"),
                      Text("Issued By: ${rx.doctorName ?? 'N/A'}"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Prescribed Medications:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: rx.items.length,
              itemBuilder: (context, idx) {
                final item = rx.items[idx];

                // 🟢 Calculate remaining quantity to default the input correctly
                final defaultDispenseAmount = item.prescribedQuantity - item.dispensedQuantity;

                // Initialize the local state tracking map entry if empty
                _dispenseAmounts.putIfAbsent(item.medicineId, () => defaultDispenseAmount);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.medicineName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                            Text(item.instructions ?? "Take as directed", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            const SizedBox(height: 4),
                            // 🟢 Clean breakdown of total vs already processed
                            Text(
                              "Prescribed: ${item.prescribedQuantity}  |  Dispensed: ${item.dispensedQuantity}",
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // 🟢 Safe UI textbox wrapped into your index map state tracking
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          key: ValueKey("${rx.id}_${item.medicineId}"),
                          initialValue: defaultDispenseAmount.toString(),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            labelText: "Dispense",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return "Req";
                            final parsed = int.tryParse(value);
                            if (parsed == null || parsed < 0) return "Invalid";
                            return null;
                          },
                          onChanged: (value) {
                            _dispenseAmounts[item.medicineId] = int.tryParse(value) ?? 0;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: provider.isSubmitting
                    ? null
                    : () async {
                  if (!_formKey.currentState!.validate()) return;

                  // 🟢 Passes the map containing customized input overrides safely to your provider logic
                  bool success = await provider.dispenseEntirePrescription(rx, token, _dispenseAmounts);
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? "Prescription Dispensed Successfully!" : "Dispense execution failed.")),
                  );
                  if (success) {
                    setState(() {
                      provider.searchedPrescription = null;
                      _dispenseAmounts.clear();
                    });
                  }
                },
                child: provider.isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Dispense Entire Prescription", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}