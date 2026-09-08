import 'package:flutter/foundation.dart';

abstract final class ApiUrl {
  static final String base = kReleaseMode
      ? "https://cadenceiq.onrender.com/api"
      : "https://94c1-2409-40d0-2f1-f53c-242d-ff0d-ae2e-a8c.ngrok-free.app/api";

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
  static const buildPlanInsight = '/activity/get-plan-insights';
  static const createGoal = '/goal/create-goal';
  static const getCurrentGoal = '/goal/current-goal';
  static const getPastGoals = '/goal/past-goals';
  static const generateDailyInsight = '/insight/create-daily-insight';
  static const getSummary = '/summary/get-summary';
  static const getAISummary = '/summary/get-summary-insight';

  // settings
  static const connectStrava = '/strava/connect';
  static const disconnectStrava = '/strava/disconnect';
}
