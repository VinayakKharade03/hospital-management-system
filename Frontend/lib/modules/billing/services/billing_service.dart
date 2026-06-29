import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/invoice.dart';

class BillingService {
  final Dio dio = ApiClient().dio;

  // ===========================
  // Get/Create Invoice by Visit
  // ===========================

  Future<Invoice> getInvoiceByVisit(int visitId) async {
    final response = await dio.post(
      "/billing/visit/$visitId",
    );

    return Invoice.fromJson(response.data);
  }

  // ===========================
  // Receive Payment
  // ===========================

  Future<void> payInvoice(
      int invoiceId,
      double amount,
      ) async {
    await dio.post(
      "/billing/pay/$invoiceId",
      queryParameters: {
        "amount": amount,
      },
    );
  }

  // ===========================
  // Close Invoice
  // ===========================

  Future<void> closeInvoice(
      int invoiceId,
      ) async {
    await dio.post(
      "/billing/close/$invoiceId",
    );
  }

  // ===========================
  // PDF
  // ===========================

  String pdfUrl(int invoiceId) {
    return "${dio.options.baseUrl}/billing/invoice/$invoiceId/pdf";
  }
}