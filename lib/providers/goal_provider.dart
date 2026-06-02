import 'package:flutter/foundation.dart';

import 'package:cadenceiq_app/models/goal.dart';
import 'package:cadenceiq_app/services/mock/mock_goal_repository.dart';

class GoalProvider extends ChangeNotifier {
  GoalProvider({MockGoalRepository? repository})
      : _repository = repository ?? MockGoalRepository();

  final MockGoalRepository _repository;

  bool _isGenerating = false;
  List<Goal> _active = [];
  List<Goal> _past = [];

  bool get isGenerating => _isGenerating;
  List<Goal> get activeGoals => _active;
  List<Goal> get pastGoals => _past;

  void load() {
    _active = _repository.getActive();
    _past = _repository.getPast();
    notifyListeners();
  }

  Goal? getById(String id) => _repository.getById(id);

  Future<Goal?> createGoal({
    required DateTime startDate,
    required DateTime endDate,
    required ExperienceLevel level,
    required String request,
  }) async {
    _isGenerating = true;
    notifyListeners();
    try {
      final goal = await _repository.createGoal(
        startDate: startDate,
        endDate: endDate,
        level: level,
        request: request,
      );
      _active = [..._active, goal];
      return goal;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
}
