import 'package:cadenceiq/core/constants/api_url.dart';
import 'package:cadenceiq/core/env/env.dart';
import 'package:cadenceiq/core/navigation/app_router.dart';
import 'package:cadenceiq/core/utils/snackbar.dart';
import 'package:cadenceiq/providers/auth_provider.dart';
import 'package:cadenceiq/store/store.dart';
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
      final Map<String, String> refreshPayload = {"token": refreshToken ?? ""};
      final response = await refreshClient.post(
        ApiUrl.refreshToken,
        data: refreshPayload,
        options: Options(headers: {"x-api-key": Env.apiKey}),
      );

      final accessToken = response.data["accessToken"];
      await TokenStorage.save(accessToken: accessToken);

      err.requestOptions.headers["Authorization"] = "Bearer $accessToken";

      final retryResponse = await refreshClient.fetch(err.requestOptions);

      handler.resolve(retryResponse);
    } catch (e) {
      final AuthProvider auth = AuthProvider();
      AppSnackbar.show(
        rootNavigatorKey.currentContext!,
        message: "Token Expired!",
      );
      auth.logout();
    }

    _isRefreshing = false;
  }
}
