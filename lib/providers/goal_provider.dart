import 'package:cadenceiq/core/navigation/app_router.dart';
import 'package:cadenceiq/models/goal_summary.dart';
import 'package:cadenceiq/providers/dashboard_provider.dart';
import 'package:cadenceiq/services/repo/goal_repo.dart';
import 'package:flutter/foundation.dart';

import 'package:cadenceiq/models/goal.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class GoalProvider extends ChangeNotifier {
  GoalProvider({GoalRepository? repository})
    : _repository = repository ?? GoalRepository();

  final GoalRepository _repository;

  bool _isGenerating = false;
  bool _isLoading = false;
  bool _isPlanInsightLoading = false;
  bool _isDailyInsightLoading = false;
  String? _errorMessage;
  TrainingTarget? _target;
  PlanInsight? _insight;
  Goal? _active;
  List<Goal> _past = [];

  bool get isGenerating => _isGenerating;
  bool get isLoading => _isLoading;
  bool get isPlanInsightLoading => _isPlanInsightLoading;
  bool get isDailyInsightLoading => _isDailyInsightLoading;
  String? get errorMessage => _errorMessage;
  Goal? get activeGoal => _active;
  TrainingTarget? get target => _target;
  PlanInsight? get insight => _insight;
  List<Goal> get pastGoals => _past;

  Goal? getById(String id) => (_active != null ? [_active, ..._past] : _past)
      .firstWhereOrNull((e) => e?.id == id);

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
    _isDailyInsightLoading = false;
    _errorMessage = null;
    _active = null;
    _target = null;
    _insight = null;
    _past = [];
  }

  Future<bool> buildPlan({
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
        goal: goal,
        maxTrainingDays: maxTrainingDays,
        maxWeeklyDistance: maxWeeklyDistance,
        maxWeeklyDuration: maxWeeklyDuration,
        preferredLongRideDay: preferredLongRideDay,
        preferredTrainingDays: preferredTrainingDays,
        preferredSessionTypes: preferredSessionTypes,
        notes: notes,
      );
      if (res.response != null) {
        _target = TrainingTarget.fromJson(res.response);
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.error?.errorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isGenerating = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<bool> createGoal({
    required DateTime startDate,
    required DateTime endDate,
    required ExperienceLevel level,
    required String request,
    required String title,
  }) async {
    _isGenerating = false;
    _errorMessage = null;
    notifyListeners();
    try {
      _isGenerating = true;
      final res = await _repository.createGoal(
        startDate: startDate,
        endDate: endDate,
        experienceLevel: level,
        customGoalRequest: request,
        title: title,
        target: _target!,
      );
      if (res.response != null) {
        final dashboard = rootNavigatorKey.currentContext!
            .read<DashboardProvider>();
        await getCurrentGoal();
        await dashboard.refresh();
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.error?.errorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isGenerating = false;
      _errorMessage = e.toString();
      return false;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<bool> buildPlanInsight() async {
    _isPlanInsightLoading = false;
    _errorMessage = null;
    notifyListeners();
    try {
      _isPlanInsightLoading = true;
      final res = await _repository.buildPlanInsight(target: _target!);
      if (res.response != null) {
        _insight = PlanInsight.fromJson(res.response);
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.error?.errorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isPlanInsightLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
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
      } else if (res.statusCode == 200) {
        _active = null;
      } else {
        _errorMessage = res.error?.errorMessage;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCurrentGoal() async {
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _repository.deleteCurrentGoal();
      final success = res.statusCode == 200 || res.statusCode == 204;
      if (success) {
        _active = null;
        final dashboard = rootNavigatorKey.currentContext
            ?.read<DashboardProvider>();
        await dashboard?.refresh();
        notifyListeners();
        return true;
      }
      _errorMessage = res.error?.errorMessage ?? 'Failed to delete goal';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
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

  Future<bool> generateDailyInsight(DateTime date) async {
    _isDailyInsightLoading = false;
    notifyListeners();
    try {
      _isDailyInsightLoading = true;
      final res = await _repository.generateDailyInsight(date: date);
      if (res.response != null) {
        await load();
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.error?.errorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isDailyInsightLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isDailyInsightLoading = false;
      notifyListeners();
    }
  }

  Future<GoalSummary?> getSummary(String goalId) async {
    try {
      final res = await _repository.getSummary(goalId: goalId);
      if (res.response != null) {
        return GoalSummary.fromJson(res.response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> getAISummary(String summaryId) async {
    try {
      final res = await _repository.getAISummary(summaryId: summaryId);
      if (res.response != null) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
