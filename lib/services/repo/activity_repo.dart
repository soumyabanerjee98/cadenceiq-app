import 'package:cadenceiq/core/constants/api_url.dart';
import 'package:cadenceiq/core/network/dio.dart';
import 'package:cadenceiq/models/activity.dart';
import 'package:dio/dio.dart';

class ActivityRepository {
  final DioClient dio = DioClient();

  Future<ApiResponse> fetch({
    required int currentPage,
    int perPage = 20,
    String? fromDate,
    String? toDate,
    String? search,
    TrainingZone? zone,
  }) async {
    try {
      final Map<String, String> query = {
        "page": currentPage.toString(),
        "perPage": perPage.toString(),
      };
      if (fromDate != null && toDate != null) {
        query['fromDate'] = fromDate;
        query['toDate'] = toDate;
      }
      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }
      if (zone != null) {
        query['zone'] = zone.name;
      }
      final res = await dio.get(ApiUrl.activities, query: query);
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(errorMessage: dio.extractError(dioErr)),
      );
    }
  }

  Future<ApiResponse> fetchSingle({required String activityId}) async {
    try {
      final res = await dio.get("${ApiUrl.singleActivity}/$activityId");
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(errorMessage: dio.extractError(dioErr)),
      );
    }
  }

  Future<ApiResponse> fetchStravaActivities({
    required int currentPage,
    int perPage = 20,
  }) async {
    try {
      final Map<String, String> query = {
        "page": currentPage.toString(),
        "perPage": perPage.toString(),
      };
      final res = await dio.get(ApiUrl.stravaActivities, query: query);
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(errorMessage: dio.extractError(dioErr)),
      );
    }
  }

  Future<ApiResponse> syncStravaActivities({
    required List<int> activityIds,
  }) async {
    try {
      final Map<String, dynamic> payload = {"activityIds": activityIds};
      final res = await dio.post(ApiUrl.syncActivities, data: payload);
      return ApiResponse(statusCode: res.statusCode, response: res.data);
    } on DioException catch (dioErr) {
      return ApiResponse(
        statusCode: dioErr.response?.statusCode,
        response: null,
        error: ServerError(errorMessage: dio.extractError(dioErr)),
      );
    }
  }

  Future<ApiResponse> fetchExperienceLevel() async {
    try {
      final res = await dio.get(ApiUrl.fetchExperience);
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
