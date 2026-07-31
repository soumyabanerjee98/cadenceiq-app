import 'package:cadenceiq/core/constants/api_url.dart';
import 'package:cadenceiq/core/network/dio.dart';
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
        error: ServerError(errorMessage: dio.extractError(dioErr)),
      );
    }
  }

  Future<ApiResponse> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final Map<String, String> payload = {
        "email": email,
        "password": password,
        "name": name,
      };
      final res = await dio.post(ApiUrl.register, data: payload);
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(errorMessage: dio.extractError(dioErr)),
      );
    }
  }

  Future<ApiResponse> sendOtp({
    required String email,
    required String reason,
  }) async {
    try {
      final Map<String, String> payload = {"email": email, "reason": reason};
      final res = await dio.post(ApiUrl.sendOtp, data: payload);
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(errorMessage: dio.extractError(dioErr)),
      );
    }
  }

  Future<ApiResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final Map<String, String> payload = {"email": email, "otp": otp};
      final res = await dio.post(ApiUrl.verifyOtp, data: payload);
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(errorMessage: dio.extractError(dioErr)),
      );
    }
  }

  Future<ApiResponse> getProfile() async {
    try {
      final res = await dio.get(ApiUrl.profile);
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(errorMessage: dio.extractError(dioErr)),
      );
    }
  }

  Future<ApiResponse> updateProfile(FormData data) async {
    try {
      final res = await dio.putForm(ApiUrl.updateProfile, data: data);
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(errorMessage: dio.extractError(dioErr)),
      );
    }
  }

  Future<ApiResponse> deleteProfile(String password) async {
    try {
      final Map<String, String> payload = {"password": password};
      final res = await dio.delete(ApiUrl.deleteAccount, data: payload);
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(errorMessage: dio.extractError(dioErr)),
      );
    }
  }
}
