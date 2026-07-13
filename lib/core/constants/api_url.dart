const String environment = "UAT";

const Map<String, String> baseUrl = {
  "UAT":
      "https://32bb-2409-40d0-2b1-5ad6-f1d4-7a5d-ea59-ac25.ngrok-free.app/api",
  "LIVE": "https://cadenceiq.onrender.com/api",
};

abstract final class ApiUrl {
  static final String base = baseUrl[environment]!;

  // auth
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const profile = '/auth/profile';
  static const refreshToken = '/auth/refresh-token';

  // activity
  static const activities = '/activity/get-activities';
}
