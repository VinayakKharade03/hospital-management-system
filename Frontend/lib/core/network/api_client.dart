import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: "http://localhost:8080/api",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        // ================= REQUEST =================
        onRequest: (options, handler) async {
          final token = await SecureStorage.getAccessToken();

          // ✅ Attach token everywhere except login & refresh
          if (token != null &&
              !options.path.contains("/auth/login") &&
              !options.path.contains("/auth/refresh")) {
            options.headers["Authorization"] = "Bearer $token";
          }

          print("➡️ ${options.method} ${options.path}");
          return handler.next(options);
        },

        // ================= ERROR =================
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              final refreshToken =
              await SecureStorage.getRefreshToken();

              if (refreshToken == null) {
                return handler.next(error);
              }

              print("🔄 Refreshing token...");

              final refreshDio = Dio(
                BaseOptions(
                  baseUrl: "http://localhost:8080/api",
                ),
              );

              final response = await refreshDio.post(
                "/auth/refresh",
                data: {"refreshToken": refreshToken},
              );

              final newAccessToken = response.data["accessToken"];

              await SecureStorage.saveAccessToken(newAccessToken);

              final opts = error.requestOptions;
              opts.headers["Authorization"] =
              "Bearer $newAccessToken";

              final cloneReq = await dio.fetch(opts);

              print("✅ Request retried");

              return handler.resolve(cloneReq);
            } catch (e) {
              print("❌ Refresh failed");

              await SecureStorage.clear();
              return handler.next(error);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }
}