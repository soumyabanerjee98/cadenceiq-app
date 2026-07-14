import 'package:cadenceiq_app/core/constants/api_url.dart';
import 'package:cadenceiq_app/core/network/dio.dart';
import 'package:dio/dio.dart';

class SettingsRepository {
  final DioClient dio = DioClient();

  Future<ApiResponse> connectStrava({
    bool newConnection = true,
    bool resetData = false,
  }) async {
    try {
      final Map<String, String> query = {
        "newConnection": newConnection.toString(),
        "resetData": resetData.toString(),
      };
      final res = await dio.get(ApiUrl.connectStrava, query: query);
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(
          errorMessage:
              dioErr.response?.data?['message'] ??
              dioErr.message ??
              "Unknown Error!",
        ),
      );
    }
  }
}
