import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../services/lab_service.dart';
import '../models/lab_test_order.dart';
import '../providers/lab_provider.dart';

class LabTestsScreen extends StatefulWidget {
  final int? visitId; // ✅ passed from visit detail screen; null = view-only mode

  const LabTestsScreen({super.key, this.visitId});

  @override
  State<LabTestsScreen> createState() => _LabTestsScreenState();
}

class _LabTestsScreenState extends State<LabTestsScreen> {
  final LabService _service = LabService();

  // Replace TextEditingController with the object selected from the autocomplete
  Map<String, dynamic>? selectedTest;

  bool loading = false;
  bool loadingOrders = true;
  List<LabTestOrder> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    setState(() => loadingOrders = true);

    try {
      final data = await _service.getAllOrders();
      setState(() => orders = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => loadingOrders = false);
  }

  Future<void> orderTest() async {
    // Check if a test was actually selected via the autocomplete
    if (selectedTest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a test from the search list")),
      );
      return;
    }

    if (widget.visitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No visit linked.")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await _service.orderLabTest(
        visitId: widget.visitId!,
        testId: selectedTest!['id'], // Get ID from the selected object
      );

      setState(() => selectedTest = null); // Reset selection
      await loadOrders();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lab Test Ordered ✅")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    setState(() => loading = false);
  }

  Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case "COMPLETED":  return Colors.green;
      case "PENDING":    return Colors.orange;
      case "ORDERED":    return Colors.blue;
      default:           return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasVisit = widget.visitId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab Tests"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadOrders,
          ),
        ],
      ),
      body: loadingOrders
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          // ✅ Order form only shown when opened from a visit
          if (hasVisit) ...[
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.science_outlined, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        "Order Lab Test",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      // ✅ Visit ID shown as read-only badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Visit #${widget.visitId}",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 1. SEARCH FIELD (Autocomplete)
                  Autocomplete<Map<String, dynamic>>(
                    displayStringForOption: (option) => option['name'],
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) return const Iterable.empty();
                      // Filters based on the availableTests list in your LabProvider
                      return context.read<LabProvider>().availableTests.where((test) =>
                          test['name'].toString().toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (selection) => setState(() => selectedTest = selection),
                    fieldViewBuilder: (context, controller, focus, onSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focus,
                        decoration: const InputDecoration(
                          labelText: "Search Test Name",
                          hintText: "e.g., Blood Sugar",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

// 2. ORDER BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: (selectedTest == null || loading) ? null : orderTest,
                      icon: loading
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Icon(Icons.add),
                      label: const Text("Order Test"),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ✅ If opened from dashboard (no visit), show info banner
          if (!hasVisit)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "To order a test, open this screen from a patient visit.",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 1),

          // ✅ Orders list
          Expanded(
            child: orders.isEmpty
                ? const Center(child: Text("No lab orders yet."))
                : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Text(
                        order.id.toString(),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      order.testName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Patient: ${order.patientName}"),
                        Text("Doctor: ${order.doctorName}"),
                        if (order.orderedAt != null)
                          Text(
                            order.orderedAt!.toLocal().toString().substring(0, 16),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor(order.status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              color: statusColor(order.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: "download",
                          child: Row(
                            children: [
                              Icon(Icons.picture_as_pdf),
                              SizedBox(width: 8),
                              Text("Download Report"),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: "refresh",
                          child: Row(
                            children: [
                              Icon(Icons.refresh),
                              SizedBox(width: 8),
                              Text("Refresh"),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == "refresh") await loadOrders();
                        if (value == "download") {
                          final url = _service.reportUrl(order.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(url)),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}