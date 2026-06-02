import 'package:cadenceiq_app/models/activity.dart';
import 'package:cadenceiq_app/services/mock/mock_data.dart';

class MockActivityRepository {
  List<Activity> getAll() => List.unmodifiable(MockData.activities);

  Activity? getById(String id) {
    try {
      return MockData.activities.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Activity> search(String query) {
    if (query.isEmpty) return getAll();
    final q = query.toLowerCase();
    return MockData.activities
        .where((a) => a.name.toLowerCase().contains(q))
        .toList();
  }

  List<Activity> filterByZone(TrainingZone? zone) {
    if (zone == null) return getAll();
    return MockData.activities.where((a) => a.zone == zone).toList();
  }

  Future<List<Activity>> fetchAll({bool simulateDelay = true}) async {
    if (simulateDelay) await Future<void>.delayed(const Duration(milliseconds: 600));
    return getAll();
  }
}
