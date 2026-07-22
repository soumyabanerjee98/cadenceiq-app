import 'package:cadenceiq_app/core/network/dio.dart';
import 'package:cadenceiq_app/services/repo/goal_repo.dart';
import 'package:flutter/foundation.dart';

import 'package:cadenceiq_app/models/goal.dart';

class GoalProvider extends ChangeNotifier {
  GoalProvider({GoalRepository? repository})
    : _repository = repository ?? GoalRepository();

  final GoalRepository _repository;

  bool _isGenerating = false;
  bool _isLoading = false;
  bool _isPlanInsightLoading = false;
  String? _errorMessage;
  TrainingTarget? _target;
  PlanInsight? _insight;
  Goal? _active;
  List<Goal> _past = [];

  bool get isGenerating => _isGenerating;
  bool get isLoading => _isLoading;
  bool get isPlanInsightLoading => _isPlanInsightLoading;
  String? get errorMessage => _errorMessage;
  Goal? get activeGoal => _active;
  TrainingTarget? get target => _target;
  PlanInsight? get insight => _insight;
  List<Goal> get pastGoals => _past;

  Goal? getById(String id) => (_active != null ? [_active, ..._past] : _past)
      .firstWhere((e) => e?.id == id);

  Future<void> load() async {
    await getCurrentGoal();
    await getPastGoals();
    notifyListeners();
  }

  void prepareNewGoal() {
    _target = null;
    _insight = null;
  }

  void reset() {
    _isGenerating = false;
    _isLoading = false;
    _isPlanInsightLoading = false;
    _errorMessage = null;
    _active = null;
    _target = null;
    _insight = null;
    _past = [];
  }

  Future<ApiResponse> buildPlan({
    required DateTime startDate,
    required DateTime endDate,
    required ExperienceLevel level,
    required String request,
  }) async {
    _isGenerating = false;
    _errorMessage = null;
    _target = null;
    notifyListeners();
    try {
      _isGenerating = true;
      final res = await _repository.buildPlan(
        startDate: startDate,
        endDate: endDate,
        level: level,
        request: request,
      );
      if (res.response != null) {
        _target = TrainingTarget.fromJson(res.response);
      } else {
        _errorMessage = res.error?.errorMessage;
      }
      notifyListeners();
      return res;
    } catch (e) {
      _isGenerating = false;
      _errorMessage = e.toString();
      return ApiResponse(
        statusCode: 500,
        response: null,
        error: ServerError(
          errorMessage: _errorMessage ?? "Something went wrong!",
        ),
      );
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> buildPlanInsight() async {
    _isPlanInsightLoading = false;
    _errorMessage = null;
    notifyListeners();
    try {
      _isPlanInsightLoading = true;
      final res = await _repository.buildPlanInsight(target: _target!);
      if (res.response != null) {
        _insight = PlanInsight.fromJson(res.response);
      } else {
        _errorMessage = res.error?.errorMessage;
      }
      notifyListeners();
    } catch (e) {
      _isPlanInsightLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isPlanInsightLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCurrentGoal() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _repository.getCurrentGoal();
      if (res.response != null) {
        _active = Goal.fromJson(res.response);
      } else if (res.statusCode != 200) {
        _errorMessage = res.error?.errorMessage;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPastGoals() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _repository.getPastGoals();
      if (res.response != null) {
        _past = (res.response as List).map((e) => Goal.fromJson(e)).toList();
      } else if (res.statusCode != 200) {
        _errorMessage = res.error?.errorMessage;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
