import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/invoice.dart';
import '../services/billing_service.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class BillingScreen extends StatefulWidget {
  final int visitId;

  const BillingScreen({
    super.key,
    required this.visitId,
  });

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final BillingService _billingService = BillingService();

  Invoice? invoice;

  bool isLoading = true;
  bool isPaying = false;
  bool isClosing = false;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    loadInvoice();
  }

  Future<void> loadInvoice() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await _billingService.getInvoiceByVisit(widget.visitId);
      setState(() {
        invoice = result;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load invoice")),
        );
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> receivePayment() async {
    if (invoice == null) return;

    if (invoice!.status.toUpperCase() == "CLOSED") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invoice is already closed")),
      );
      return;
    }

    if (invoice!.dueAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invoice is already fully paid")),
      );
      return;
    }

    final controller = TextEditingController();
    final dueAmount = invoice!.dueAmount;
    String? errorText;

    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Receive Payment"),
              content: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Amount",
                  helperText: "Due: ₹${dueAmount.toStringAsFixed(2)}",
                  errorText: errorText,
                  border: const OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final parsed = double.tryParse(controller.text);
                    if (parsed == null || parsed <= 0) {
                      setDialogState(() => errorText = "Enter a valid amount");
                      return;
                    }
                    if (parsed > dueAmount) {
                      setDialogState(() => errorText =
                      "Cannot exceed due amount (₹${dueAmount.toStringAsFixed(2)})");
                      return;
                    }
                    Navigator.pop(context, parsed);
                  },
                  child: const Text("Pay"),
                ),
              ],
            );
          },
        );
      },
    );

    if (amount == null) return;

    setState(() => isPaying = true);

    try {
      await _billingService.payInvoice(invoice!.id, amount);
      await loadInvoice();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment successful")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment failed")),
        );
      }
    }

    if (mounted) setState(() => isPaying = false);
  }

  Future<void> closeInvoice() async {
    if (invoice == null) return;

    if (invoice!.status.toUpperCase() == "CLOSED") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invoice is already closed")),
      );
      return;
    }

    if (invoice!.dueAmount > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Outstanding Balance"),
          content: Text(
            "₹${invoice!.dueAmount.toStringAsFixed(2)} is still due. "
                "Close this invoice anyway?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Close Anyway"),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => isClosing = true);

    try {
      await _billingService.closeInvoice(invoice!.id);
      await loadInvoice();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invoice closed")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to close invoice")),
        );
      }
    }

    if (mounted) setState(() => isClosing = false);
  }

  // ─── PDF DOWNLOAD ──────────────────────────────────────────────────────────
  Future<void> downloadPdf() async {
    if (invoice == null) return;

    setState(() => isDownloading = true);

    try {
      // dio already has the Bearer token via ApiClient interceptor
      final response = await _billingService.dio.get(
        "/billing/invoice/${invoice!.id}/pdf",
        options: Options(responseType: ResponseType.bytes),
      );

      // Save to temp directory
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/invoice_${invoice!.id}.pdf');
      await file.writeAsBytes(response.data);

      // Open with system PDF viewer
      final result = await OpenFile.open(file.path);

      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not open PDF: ${result.message}")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to download PDF: $e")),
        );
      }
    }

    if (mounted) setState(() => isDownloading = false);
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Billing")),
        body: const Center(
          child: Text(
            "No Invoice Found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Billing",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadInvoice,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Patient card ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Patient", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    invoice!.patientName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Chip(label: Text(invoice!.status)),
                      const SizedBox(width: 10),
                      Chip(
                        backgroundColor: Colors.green.shade100,
                        label: Text(invoice!.paymentStatus),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Items ─────────────────────────────────────────────────────
            const Text(
              "Invoice Items",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            ...invoice!.items.map(
                  (item) => Card(
                elevation: 0,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(Icons.medical_services, color: Colors.green),
                  ),
                  title: Text(item.itemName),
                  subtitle: Text("Qty : ${item.quantity}"),
                  trailing: Text(
                    "₹${item.total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ── Totals row ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const Text("Total"),
                          const SizedBox(height: 8),
                          Text(
                            "₹${invoice!.totalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const Text("Paid"),
                          const SizedBox(height: 8),
                          Text(
                            "₹${invoice!.paidAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const Text("Due"),
                          const SizedBox(height: 8),
                          Text(
                            "₹${invoice!.dueAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ── Action buttons ────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: (isPaying ||
                        invoice!.status.toUpperCase() == "CLOSED" ||
                        invoice!.dueAmount <= 0)
                        ? null
                        : receivePayment,
                    icon: const Icon(Icons.payments),
                    label: Text(isPaying ? "Processing..." : "Receive Payment"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed:
                    (isClosing || invoice!.status.toUpperCase() == "CLOSED")
                        ? null
                        : closeInvoice,
                    icon: const Icon(Icons.check_circle),
                    label: Text(
                      isClosing
                          ? "Closing..."
                          : invoice!.status.toUpperCase() == "CLOSED"
                          ? "Closed"
                          : "Close Invoice",
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // ── Download PDF button ───────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isDownloading ? null : downloadPdf,
                icon: isDownloading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.picture_as_pdf),
                label: Text(
                  isDownloading ? "Opening PDF..." : "Download Invoice PDF",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}