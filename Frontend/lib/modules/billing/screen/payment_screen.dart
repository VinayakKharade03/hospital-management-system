import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final int invoiceId;

  const PaymentScreen({
    super.key,
    required this.invoiceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
      ),
      body: Center(
        child: Text(
          "Payment for Invoice #$invoiceId",
        ),
      ),
    );
  }
}