import 'package:cadenceiq_app/core/network/dio.dart';
import 'package:cadenceiq_app/models/user_profile.dart';
import 'package:cadenceiq_app/services/repo/auth_repo.dart';
import 'package:cadenceiq_app/store/store.dart';
import 'package:flutter/foundation.dart';

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
    if (res.error == null) {
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

    final success = await _repository.signup(
      name: name,
      email: email,
      password: password,
    );
    if (success) {
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.error;
      _errorMessage = 'Please check your details and try again.';
    }
    notifyListeners();
  }

  void logout() async {
    _state = AuthState.unauthenticated;
    await LocalStorage.removeUserProfile();
    await TokenStorage.clear();
    notifyListeners();
  }

  void setAuthenticated() {
    _state = AuthState.authenticated;
    notifyListeners();
  }
}
