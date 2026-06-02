import 'package:flutter/foundation.dart';

import 'package:cadenceiq_app/services/mock/mock_user_repository.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider({MockUserRepository? repository})
      : _repository = repository ?? MockUserRepository();

  final MockUserRepository _repository;

  AuthState _state = AuthState.initial;
  String? _errorMessage;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;

  Future<void> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final success = await _repository.login(email, password);
    if (success) {
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.error;
      _errorMessage = 'Invalid email or password. Use any email and 6+ char password.';
    }
    notifyListeners();
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

  void logout() {
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  void setAuthenticated() {
    _state = AuthState.authenticated;
    notifyListeners();
  }
}
