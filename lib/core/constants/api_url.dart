const String environment = "UAT";

const Map<String, String> baseUrl = {
  "UAT":
      "https://e752-2409-40d0-3019-d689-b519-73c3-47b7-721.ngrok-free.app/api",
  "LIVE": "https://cadenceiq.onrender.com/api",
};

abstract final class ApiUrl {
  static final String base = baseUrl[environment]!;

  // auth
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const sendOtp = '/auth/send-otp';
  static const verifyOtp = '/auth/verify-otp';
  static const profile = '/auth/profile';
  static const updateProfile = '/auth/update-profile';
  static const refreshToken = '/auth/refresh-token';
  static const deleteAccount = '/auth/delete-account';

  // activity
  static const activities = '/activity/get-activities';
  static const singleActivity = '/activity/get-activity';
  static const stravaActivities = '/activity/preview-strava-activities';
  static const syncActivities = '/activity/sync-activities';
  static const fetchExperience = '/activity/athlete-experience';

  // goal
  static const buildPlan = '/activity/get-plan';
  static const getCurrentGoal = '/goal/current-goal';
  static const getPastGoals = '/goal/past-goals';

  // settings
  static const connectStrava = '/strava/connect';
  static const disconnectStrava = '/strava/disconnect';
}
