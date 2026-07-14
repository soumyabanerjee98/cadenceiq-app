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

  static Future<void> setUserProfileId(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, profileId);
  }

  static Future<String?> getUserProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userProfileKey);
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
