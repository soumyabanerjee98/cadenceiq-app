import 'package:cadenceiq_app/core/env/env.dart';
import 'package:cadenceiq_app/store/store.dart';
import 'package:dio/dio.dart';

class ApiInterceptor extends QueuedInterceptor {
  final Dio refreshClient;

  ApiInterceptor(this.refreshClient);

  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.addAll({
      "x-api-key": Env.apiKey,
      "Accept": "application/json",
      "Content-Type": "application/json",
    });

    final token = await TokenStorage.getAccessToken();

    if (token != null) {
      options.headers["Authorization"] = "Bearer $token";
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      handler.next(err);
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await TokenStorage.getRefreshToken();

      final response = await refreshClient.post(
        "/auth/refresh",
        data: {"refreshToken": refreshToken},
        options: Options(headers: {"x-api-key": Env.apiKey}),
      );

      final accessToken = response.data["accessToken"];
      final newRefreshToken = response.data["refreshToken"];

      await TokenStorage.save(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );

      err.requestOptions.headers["Authorization"] = "Bearer $accessToken";

      final retryResponse = await refreshClient.fetch(err.requestOptions);

      handler.resolve(retryResponse);
    } catch (_) {
      await TokenStorage.clear();
      handler.next(err);
    }

    _isRefreshing = false;
  }
}
