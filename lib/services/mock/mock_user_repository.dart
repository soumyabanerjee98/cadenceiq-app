import 'package:cadenceiq_app/models/goal.dart';
import 'package:cadenceiq_app/models/training_metrics.dart';
import 'package:cadenceiq_app/models/user_profile.dart';
import 'package:cadenceiq_app/services/mock/mock_data.dart';

class MockUserRepository {
  UserProfile getProfile() => MockData.user;
  TrainingMetrics getMetrics() => MockData.metrics;
  TodaySession getTodaySession() => MockData.todaySession;
  Goal getCurrentGoal() => MockData.activeGoal;

  Future<UserProfile?> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (email.isNotEmpty && password.length >= 6) return getProfile();
    return null;
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return name.isNotEmpty && email.contains('@') && password.length >= 6;
  }
}
