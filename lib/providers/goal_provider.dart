import 'package:cadenceiq_app/services/repo/goal_repo.dart';
import 'package:flutter/foundation.dart';

import 'package:cadenceiq_app/models/goal.dart';

class GoalProvider extends ChangeNotifier {
  GoalProvider({GoalRepository? repository})
    : _repository = repository ?? GoalRepository();

  final GoalRepository _repository;

  bool _isGenerating = false;
  bool _isLoading = false;
  String? _errorMessage;
  TrainingTarget? _target;
  Goal? _active;
  List<Goal> _past = [];

  bool get isGenerating => _isGenerating;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Goal? get activeGoal => _active;
  TrainingTarget? get target => _target;
  List<Goal> get pastGoals => _past;

  Goal? getById(String id) => (_active != null ? [_active, ..._past] : _past)
      .firstWhere((e) => e?.id == id);

  Future<void> load() async {
    await getCurrentGoal();
    await getPastGoals();
    notifyListeners();
  }

  Future<void> buildPlan({
    required DateTime startDate,
    required DateTime endDate,
    required ExperienceLevel level,
    required String request,
  }) async {
    _isGenerating = true;
    notifyListeners();
    try {
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
    } finally {
      _isGenerating = false;
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
