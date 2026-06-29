import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import '../services/lab_service.dart';
import '../models/lab_test_order.dart';

class LabReportsScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const LabReportsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<LabReportsScreen> createState() => _LabReportsScreenState();
}

class _LabReportsScreenState extends State<LabReportsScreen> {
  final LabService _service = LabService();

  List<LabTestOrder> reports = [];
  bool loading = true;

  // Track which order is currently downloading
  int? downloadingOrderId;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    setState(() => loading = true);
    try {
      final data = await _service.getPatientReports(widget.patientId);

      // Sort by orderedAt descending — newest first, nulls at bottom
      data.sort((a, b) {
        if (a.orderedAt == null && b.orderedAt == null) return 0;
        if (a.orderedAt == null) return 1;
        if (b.orderedAt == null) return -1;
        return b.orderedAt!.compareTo(a.orderedAt!);
      });

      setState(() => reports = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load reports: $e")),
      );
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> openReport(LabTestOrder order) async {
    setState(() => downloadingOrderId = order.id);

    try {
      // dio.download sends the Bearer token — no 403
      final filePath = await _service.downloadReport(order.id);
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not open PDF: ${result.message}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download report: $e")),
      );
    }

    if (mounted) setState(() => downloadingOrderId = null);
  }

  Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case "COMPLETED":
        return Colors.green;
      case "ORDERED":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.patientName} — Lab Reports"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadReports),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
          ? const Center(child: Text("No lab reports found."))
          : ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final order = reports[index];
          final isDownloading = downloadingOrderId == order.id;
          final isCompleted = order.status.toUpperCase() == "COMPLETED";

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              title: Text(order.testName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Doctor: ${order.doctorName}"),
                  if (order.orderedAt != null)
                    Text(
                      order.orderedAt!
                          .toLocal()
                          .toString()
                          .substring(0, 16),
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
                      color: statusColor(order.status)
                          .withOpacity(0.15),
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
              trailing: isCompleted
                  ? isDownloading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : IconButton(
                icon: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                ),
                onPressed: () => openReport(order),
              )
                  : null,
            ),
          );
        },
      ),
    );
  }
}