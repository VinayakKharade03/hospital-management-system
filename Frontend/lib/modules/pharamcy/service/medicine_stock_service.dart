import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_client.dart';
import '../models/medicine_stock.dart';

class MedicineStockService {
  final Dio dio = ApiClient().dio;

  static const String _base = "/pharmacy/stock";

  // ===============================
  // ADD STOCK
  // ===============================
  Future<MedicineStock> addStock({
    required int medicineId,
    required int quantity,
    required String batchNumber,
    required DateTime mfgDate,
    required DateTime expiryDate,
    required String supplier,
  }) async {
    final fmt = DateFormat('yyyy-MM-dd');

    final response = await dio.post(
      "$_base/add-stock",
      data: {
        "medicineId": medicineId,
        "quantity": quantity,
        "batchNumber": batchNumber,
        "mfgDate": fmt.format(mfgDate),
        "expiryDate": fmt.format(expiryDate),
        "supplier": supplier,
      },
    );

    return MedicineStock.fromJson(response.data);
  }

  // ===============================
  // DISPENSE
  // ===============================
  Future<void> dispense({
    required int visitId,
    required int medicineId,
    required int quantity,
  }) async {
    await dio.post(
      "$_base/dispense",
      data: {
        "visitId": visitId,
        "medicineId": medicineId,
        "quantity": quantity,
      },
    );
  }

  // ===============================
  // AVAILABLE STOCK (🟢 ADDED)
  // ===============================
  Future<List<MedicineStock>> getAvailableStock() async {
    final response = await dio.get("$_base/available");

    return (response.data as List)
        .map((e) => MedicineStock.fromJson(e))
        .toList();
  }

  // ===============================
  // EXPIRING MEDICINES
  // ===============================
  Future<List<MedicineStock>> getExpiring(int days) async {
    final response = await dio.get(
      "$_base/expiring",
      queryParameters: {"days": days},
    );

    return (response.data as List)
        .map((e) => MedicineStock.fromJson(e))
        .toList();
  }

  // ===============================
  // LOW STOCK CHECK
  // ===============================
  Future<bool> isLowStock({
    required int medicineId,
    required int threshold,
  }) async {
    final response = await dio.get(
      "$_base/low-stock",
      queryParameters: {
        "medicineId": medicineId,
        "threshold": threshold,
      },
    );

    return response.data as bool;
  }
}