import 'package:flutter/foundation.dart';

import 'package:cadenceiq_app/models/goal.dart';
import 'package:cadenceiq_app/models/training_metrics.dart';
import 'package:cadenceiq_app/models/user_profile.dart';
import 'package:cadenceiq_app/services/mock/mock_user_repository.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({MockUserRepository? repository})
      : _repository = repository ?? MockUserRepository();

  final MockUserRepository _repository;

  bool _isLoading = false;

  UserProfile get user => _repository.getProfile();
  TrainingMetrics get metrics => _repository.getMetrics();
  TodaySession get todaySession => _repository.getTodaySession();
  Goal get currentGoal => _repository.getCurrentGoal();
  bool get isLoading => _isLoading;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _isLoading = false;
    notifyListeners();
  }
}
