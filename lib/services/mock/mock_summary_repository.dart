import 'package:cadenceiq/models/goal_summary.dart';
import 'package:cadenceiq/services/mock/mock_data.dart';

class MockSummaryRepository {
  List<GoalSummary> getAll() => List.unmodifiable(MockData.summaries);

  GoalSummary? getById(String id) {
    try {
      return MockData.summaries.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
