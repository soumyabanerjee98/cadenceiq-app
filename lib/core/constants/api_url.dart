const String environment = "UAT";

const Map<String, String> baseUrl = {
  "UAT":
      "https://d93c-2409-40d0-2b1-5ad6-69a8-e04a-78c8-2298.ngrok-free.app/api",
  "LIVE": "https://cadenceiq.onrender.com/api",
};

abstract final class ApiUrl {
  static final String base = baseUrl[environment]!;

  // auth
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const profile = '/auth/profile';
  static const updateProfile = '/auth/update-profile';
  static const refreshToken = '/auth/refresh-token';

  // activity
  static const activities = '/activity/get-activities';
  static const singleActivity = '/activity/get-activity';
  static const stravaActivities = '/activity/preview-strava-activities';
  static const syncActivities = '/activity/sync-activities';

  // settings
  static const connectStrava = '/strava/connect';
  static const disconnectStrava = '/strava/disconnect';
}
