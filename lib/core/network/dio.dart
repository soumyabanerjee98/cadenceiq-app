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
}
