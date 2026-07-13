import 'package:cadenceiq_app/core/constants/api_url.dart';
import 'package:cadenceiq_app/core/network/dio.dart';
import 'package:cadenceiq_app/models/user_profile.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final DioClient dio = DioClient();

  Future<ApiResponse> login(String email, String password) async {
    try {
      final Map<String, String> payload = {
        "email": email,
        "password": password,
      };
      final res = await dio.post(ApiUrl.login, data: payload);
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(
          errorMessage: dioErr.response?.data?['message'] ?? "Unknown Error!",
        ),
      );
    }
  }

  Future<dynamic> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final Map<String, String> payload = {
      "email": email,
      "password": password,
      "name": name,
    };
    final res = await dio.post(ApiUrl.register, data: payload);
    print(res);
    return null;
  }

  Future<ApiResponse> getProfile() async {
    try {
      final res = await dio.get(ApiUrl.profile);
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(
          errorMessage: dioErr.response?.data?['message'] ?? "Unknown Error!",
        ),
      );
    }
  }
}
