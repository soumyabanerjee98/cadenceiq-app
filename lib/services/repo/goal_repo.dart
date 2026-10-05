import 'package:cadenceiq/core/constants/api_url.dart';
import 'package:cadenceiq/core/network/dio.dart';
import 'package:cadenceiq/models/goal.dart';
import 'package:dio/dio.dart';

class GoalRepository {
  final DioClient dio = DioClient();

  Future<ApiResponse> buildPlan({
    required DateTime startDate,
    required DateTime endDate,
    required ExperienceLevel level,
    required TrainingGoal goal,
    int? maxTrainingDays,
    int? maxWeeklyDistance,
    int? maxWeeklyDuration,
    Weekday? preferredLongRideDay,
    required List<Weekday> preferredTrainingDays,
    required List<PlanType> preferredSessionTypes,
    String? notes,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        "startDate": startDate.toIso8601String().split("T")[0],
        "endDate": endDate.toIso8601String().split("T")[0],
        "experienceLevel": level.name,
        "goal": goal.apiValue,
        "preferredTrainingDays":
            preferredTrainingDays.map((d) => d.apiValue).toList(),
        "preferredSessionTypes":
            preferredSessionTypes.map((t) => t.apiValue).toList(),
      };
      if (maxTrainingDays != null) {
        payload["maxTrainingDays"] = maxTrainingDays;
      }
      if (maxWeeklyDistance != null) {
        payload["maxWeeklyDistance"] = maxWeeklyDistance;
      }
      if (maxWeeklyDuration != null) {
        payload["maxWeeklyDuration"] = maxWeeklyDuration;
      }
      if (preferredLongRideDay != null) {
        payload["preferredLongRideDay"] = preferredLongRideDay.apiValue;
      }
      final trimmedNotes = notes?.trim();
      if (trimmedNotes != null && trimmedNotes.isNotEmpty) {
        payload["notes"] = trimmedNotes;
      }
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

  Future<ApiResponse> createGoal({
    required DateTime startDate,
    required DateTime endDate,
    required String title,
    required ExperienceLevel experienceLevel,
    required String customGoalRequest,
    required TrainingTarget target,
  }) async {
    try {
      Map<String, dynamic> payload = {
        "startDate": startDate.toIso8601String().split("T")[0],
        "endDate": endDate.toIso8601String().split("T")[0],
        "experienceLevel": experienceLevel.name,
        "customGoalRequest": customGoalRequest,
        "title": title,
      };
      payload.addAll(target.toJson());
      final res = await dio.post(ApiUrl.createGoal, data: payload);
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

  Future<ApiResponse> generateDailyInsight({required DateTime date}) async {
    try {
      Map<String, dynamic> payload = {
        "date": date.toIso8601String().split("T")[0],
      };
      final res = await dio.post(ApiUrl.generateDailyInsight, data: payload);
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(errorMessage: dio.extractError(dioErr)),
      );
    }
  }

  Future<ApiResponse> getSummary({required String goalId}) async {
    try {
      final res = await dio.get('${ApiUrl.getSummary}/$goalId');
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(errorMessage: dio.extractError(dioErr)),
      );
    }
  }

  Future<ApiResponse> getAISummary({required String summaryId}) async {
    try {
      final res = await dio.get('${ApiUrl.getAISummary}/$summaryId');
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
