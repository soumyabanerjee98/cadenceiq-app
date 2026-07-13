const String environment = "UAT";

const Map<String, String> baseUrl = {
  "UAT":
      "https://6454-2409-40d0-2b1-5ad6-a8ff-bd23-4d80-4420.ngrok-free.app/api",
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

  // settings
  static const connectStrava = '/strava/connect';
}
