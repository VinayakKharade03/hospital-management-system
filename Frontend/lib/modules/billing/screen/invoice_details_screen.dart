import 'package:flutter/material.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final int invoiceId;

  const InvoiceDetailsScreen({
    super.key,
    required this.invoiceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice Details"),
      ),
      body: Center(
        child: Text(
          "Invoice Details #$invoiceId",
        ),
      ),
    );
  }
}