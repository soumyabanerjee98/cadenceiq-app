import 'package:cadenceiq_app/services/repo/auth_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:cadenceiq_app/models/user_profile.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  bool _isLoading = false;

  UserProfile? user;
  // TrainingMetrics get metrics => _repository.getMetrics();
  // TodaySession get todaySession => _repository.getTodaySession();
  // Goal get currentGoal => _repository.getCurrentGoal();
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
    await getProfile();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getProfile() async {
    user = await _repository.getProfile();
  }
}
