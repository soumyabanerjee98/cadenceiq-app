import 'package:cadenceiq_app/models/goal.dart';
import 'package:cadenceiq_app/services/mock/mock_data.dart';

class MockGoalRepository {
  List<Goal> getActive() =>
      MockData.goals.where((g) => g.status == GoalStatus.active).toList();

  List<Goal> getPast() =>
      MockData.goals.where((g) => g.status == GoalStatus.completed).toList();

  Goal? getById(String id) {
    try {
      return MockData.goals.firstWhere((g) => g.id == id);
    } catch (_) {
      if (id == MockData.activeGoal.id) return MockData.activeGoal;
      return null;
    }
  }

  Future<Goal> createGoal({
    required DateTime startDate,
    required DateTime endDate,
    required ExperienceLevel level,
    required String request,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return Goal(
      id: 'goal-new-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Custom Training Goal',
      startDate: startDate,
      endDate: endDate,
      experienceLevel: level,
      currentLoad: 0,
      targetLoad: 400,
      adjustedLoad: 380,
      progress: 0,
      status: GoalStatus.active,
      goalRequest: request,
    );
  }
}
