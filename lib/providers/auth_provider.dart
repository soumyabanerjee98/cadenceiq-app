import 'package:cadenceiq_app/core/constants/route_paths.dart';
import 'package:cadenceiq_app/core/navigation/app_router.dart';
import 'package:cadenceiq_app/core/network/dio.dart';
import 'package:cadenceiq_app/services/repo/auth_repo.dart';
import 'package:cadenceiq_app/store/store.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

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

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final res = await _repository.signup(
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
}
