import 'package:cadenceiq_app/core/navigation/app_router.dart';
import 'package:cadenceiq_app/providers/activity_provider.dart';
import 'package:cadenceiq_app/providers/goal_provider.dart';
import 'package:cadenceiq_app/services/repo/auth_repo.dart';
import 'package:cadenceiq_app/store/store.dart';
import 'package:flutter/foundation.dart';
import 'package:cadenceiq_app/models/user_profile.dart';
import 'package:provider/provider.dart';

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

  void reset() {
    _isLoading = false;
    user = null;
  }

  Future<void> refresh() async {
    final activity = rootNavigatorKey.currentContext!.read<ActivityProvider>();
    final goal = rootNavigatorKey.currentContext!.read<GoalProvider>();
    _isLoading = true;
    notifyListeners();
    await getProfile();
    await activity.load();
    await goal.load();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getProfile() async {
    final res = await _repository.getProfile();
    if (res.response != null) {
      final userProfile = UserProfile.fromJson(res.response);
      await LocalStorage.setUserProfileId(userProfile.id);
      user = userProfile;
    }
  }
}
