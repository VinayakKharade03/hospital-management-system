import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/medicine.dart';

class MedicineService {
  // ✅ Now uses the shared Dio client (token attach + auto-refresh interceptor)
  // instead of a standalone Dio() instance.
  final Dio dio = ApiClient().dio;

  // ApiClient baseUrl already ends with "/api", so paths below
  // must NOT repeat the "/api" prefix.
  static const String _base = "/pharmacy/medicines";

  // ===============================
  // SEARCH
  // ===============================
  Future<List<Medicine>> searchMedicines(String query) async {
    if (query.trim().isEmpty) return [];

    final response = await dio.get(
      "$_base/search",
      queryParameters: {"query": query},
    );

    return (response.data as List)
        .map((e) => Medicine.fromJson(e))
        .toList();
  }

  // ===============================
  // GET ALL
  // ===============================
  Future<List<Medicine>> getAllMedicines() async {
    final response = await dio.get(_base);

    return (response.data as List)
        .map((e) => Medicine.fromJson(e))
        .toList();
  }

  // ===============================
  // GET BY ID
  // ===============================
  Future<Medicine> getMedicine(int id) async {
    final response = await dio.get("$_base/$id");
    return Medicine.fromJson(response.data);
  }

  // ===============================
  // ADD
  // ===============================
  Future<Medicine> addMedicine({
    required String name,
    double? unitPrice,
  }) async {
    final response = await dio.post(
      _base,
      data: {
        "name": name,
        "unitPrice": unitPrice,
      },
    );

    return Medicine.fromJson(response.data);
  }

  // ===============================
  // UPDATE
  // ===============================
  Future<Medicine> updateMedicine({
    required int id,
    required String name,
    double? unitPrice,
  }) async {
    final response = await dio.put(
      "$_base/$id",
      data: {
        "name": name,
        "unitPrice": unitPrice,
      },
    );

    return Medicine.fromJson(response.data);
  }

  // ===============================
  // DELETE
  // ===============================
  Future<void> deleteMedicine(int id) async {
    await dio.delete("$_base/$id");
  }
}