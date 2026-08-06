import 'package:cadenceiq/core/constants/route_paths.dart';
import 'package:cadenceiq/core/navigation/app_router.dart';
import 'package:cadenceiq/core/network/dio.dart';
import 'package:cadenceiq/core/utils/formatters.dart';
import 'package:cadenceiq/features/auth/otp_screen.dart';
import 'package:cadenceiq/providers/activity_provider.dart';
import 'package:cadenceiq/providers/dashboard_provider.dart';
import 'package:cadenceiq/providers/goal_provider.dart';
import 'package:cadenceiq/services/repo/auth_repo.dart';
import 'package:cadenceiq/store/store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  AuthState _state = AuthState.initial;
  String? _errorMessage;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;

  void reset() {
    _state = AuthState.initial;
    _errorMessage = null;
  }

  Future<ApiResponse> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final ApiResponse res = await _repository.login(email, password);
    if (res.response != null) {
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.error;
      _errorMessage = res.error?.errorMessage;
    }
    notifyListeners();
    return res;
  }

  Future<ApiResponse> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final ApiResponse res = await _repository.signup(
      name: name,
      email: email,
      password: password,
    );
    if (res.response != null) {
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.error;
      _errorMessage = res.error?.errorMessage;
    }
    notifyListeners();
    return res;
  }

  Future<ApiResponse> sendOtp({
    required String email,
    required OtpReason reason,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final ApiResponse res = await _repository.sendOtp(
      email: email,
      reason: Formatters.otpReason(reason),
    );
    if (res.response != null) {
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.error;
      _errorMessage = res.error?.errorMessage;
    }
    notifyListeners();
    return res;
  }

  Future<ApiResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final ApiResponse res = await _repository.verifyOtp(email: email, otp: otp);
    if (res.response != null) {
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.error;
      _errorMessage = res.error?.errorMessage;
    }
    notifyListeners();
    return res;
  }

  Future<ApiResponse> resetPassword({required String password}) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    Map<String, dynamic> payload = {"password": password};
    FormData formData = FormData.fromMap(payload);
    final ApiResponse res = await _repository.updateProfile(formData);
    if (res.response != null) {
      _state = AuthState.unauthenticated;
      _errorMessage = null;
    } else {
      _state = AuthState.error;
      _errorMessage = res.error?.errorMessage;
    }
    notifyListeners();
    return res;
  }

  Future<ApiResponse> deleteAccount({required String password}) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final ApiResponse res = await _repository.deleteProfile(password);
    if (res.response != null) {
      logout();
    } else {
      _state = AuthState.error;
      _errorMessage = res.error?.errorMessage;
    }
    notifyListeners();
    return res;
  }

  void logout() async {
    _state = AuthState.unauthenticated;
    await LocalStorage.removeUserProfile();
    await TokenStorage.clear();
    rootNavigatorKey.currentContext?.go(RoutePaths.login);
    notifyListeners();
  }

  void setAuthenticated() {
    _state = AuthState.authenticated;
    notifyListeners();
  }

  void clearErrors() {
    _errorMessage = null;
  }

  void cleanUpProviders({required BuildContext context}) {
    reset();
    final ActivityProvider activityProvider = context.read<ActivityProvider>();
    final DashboardProvider dashboardProvider = context
        .read<DashboardProvider>();
    final GoalProvider goalProvider = context.read<GoalProvider>();
    activityProvider.reset();
    dashboardProvider.reset();
    goalProvider.reset();
  }
}
