import 'package:cadenceiq_app/core/constants/api_url.dart';
import 'package:cadenceiq_app/core/network/dio.dart';
import 'package:cadenceiq_app/models/goal.dart';
import 'package:dio/dio.dart';

class GoalRepository {
  final DioClient dio = DioClient();

  Future<ApiResponse> buildPlan({
    required DateTime startDate,
    required DateTime endDate,
    required ExperienceLevel level,
    required String request,
  }) async {
    try {
      Map<String, String> payload = {
        "startDate": startDate.toIso8601String().split("T")[0],
        "endDate": endDate.toIso8601String().split("T")[0],
        "experienceLevel": level.name,
        "customGoalRequirements": request,
      };
      final res = await dio.post(ApiUrl.buildPlan, data: payload);
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(errorMessage: dio.extractError(dioErr)),
      );
    }
  }

  Future<ApiResponse> buildPlanInsight({required TrainingTarget target}) async {
    try {
      Map<String, dynamic> payload = target.toJson();
      final res = await dio.post(ApiUrl.buildPlanInsight, data: payload);
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(errorMessage: dio.extractError(dioErr)),
      );
    }
  }

  Future<ApiResponse> getCurrentGoal() async {
    try {
      final res = await dio.get(ApiUrl.getCurrentGoal);
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(errorMessage: dio.extractError(dioErr)),
      );
    }
  }

  Future<ApiResponse> getPastGoals() async {
    try {
      final res = await dio.get(ApiUrl.getPastGoals);
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
