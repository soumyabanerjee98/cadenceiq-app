import 'dart:convert';

import 'package:cadenceiq_app/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _onboardingKey = 'onboarding_completed';
  static const _userProfileKey = 'user_profile';

  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_onboardingKey, true);
  }

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<void> setUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_userProfileKey, jsonEncode(profile.toJson()));
  }

  static Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_userProfileKey) == null) {
      return null;
    }
    final UserProfile profile = UserProfile.fromJson(
      jsonDecode(prefs.getString(_userProfileKey) ?? ""),
    );

    return profile;
  }

  static Future<bool> removeUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.remove(_userProfileKey);
  }
}

class TokenStorage {
  static const String _accessToken = 'access_token';
  static const String _refreshToken = 'refresh_token';

  static Future<void> save({
    required String accessToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_accessToken, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_refreshToken, refreshToken);
    }
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_accessToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_refreshToken);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessToken);
    await prefs.remove(_refreshToken);
  }
}
