import 'dart:async';

import 'package:cadenceiq_app/core/constants/api_url.dart';
import 'package:cadenceiq_app/core/network/api_interceptor.dart';
import 'package:dio/dio.dart';

class ServerError {
  const ServerError({required this.errorMessage});
  final String errorMessage;
}

class ApiResponse {
  final int? statusCode;
  final dynamic response;
  final ServerError? error;

  const ApiResponse({
    required this.statusCode,
    required this.response,
    this.error,
  });
}

class DioClient {
  DioClient._();

  static final DioClient instance = DioClient._();

  factory DioClient() => instance;

  late final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiUrl.base,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
      contentType: Headers.jsonContentType,
      headers: {Headers.acceptHeader: "application/json"},
    ),
  );

  void initialize() {
    final refreshClient = Dio(BaseOptions(baseUrl: ApiUrl.base));

    dio.interceptors.add(ApiInterceptor(refreshClient));

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  //---------------------- GET ----------------------//

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return dio.get<T>(
      path,
      queryParameters: query,
      options: options,
      cancelToken: cancelToken,
    );
  }

  //---------------------- POST ----------------------//

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: query,
      options: options,
    );
  }

  Future<Response<T>> postForm<T>(
    String path, {
    FormData? data,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: query,
      options:
          options ?? Options(contentType: Headers.multipartFormDataContentType),
    );
  }

  //---------------------- PUT ----------------------//

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return dio.put<T>(
      path,
      data: data,
      queryParameters: query,
      options: options,
    );
  }

  Future<Response<T>> putForm<T>(
    String path, {
    FormData? data,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return dio.put<T>(
      path,
      data: data,
      queryParameters: query,
      options:
          options ?? Options(contentType: Headers.multipartFormDataContentType),
    );
  }

  //---------------------- PATCH ----------------------//

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return dio.patch<T>(
      path,
      data: data,
      queryParameters: query,
      options: options,
    );
  }

  Future<Response<T>> patchForm<T>(
    String path, {
    FormData? data,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return dio.patch<T>(
      path,
      data: data,
      queryParameters: query,
      options:
          options ?? Options(contentType: Headers.multipartFormDataContentType),
    );
  }

  //---------------------- DELETE ----------------------//

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return dio.delete<T>(
      path,
      data: data,
      queryParameters: query,
      options: options,
    );
  }

  String extractError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timed out.";

      case DioExceptionType.sendTimeout:
        return "Request timed out.";

      case DioExceptionType.receiveTimeout:
        return "Server took too long to respond.";

      case DioExceptionType.connectionError:
        return "Unable to connect to the server. Check your internet connection.";

      case DioExceptionType.badCertificate:
        return "Invalid SSL certificate.";

      case DioExceptionType.cancel:
        return "Request cancelled.";

      case DioExceptionType.badResponse:
        final data = e.response?.data;

        if (data is Map<String, dynamic>) {
          return data['message']?.toString() ??
              data['error']?.toString() ??
              'Server error (${e.response?.statusCode})';
        }

        if (data is String) {
          return data;
        }

        return "Server error (${e.response?.statusCode})";

      case DioExceptionType.unknown:
        return e.error?.toString() ?? e.message ?? "Unexpected error occurred.";

      default:
        return "Unexpected error occurred.";
    }
  }
}
