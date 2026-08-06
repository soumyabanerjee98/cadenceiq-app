import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cadenceiq/core/constants/route_paths.dart';
import 'package:cadenceiq/core/utils/app_animations.dart';
import 'package:cadenceiq/features/activities/sync_activities_list.dart';
import 'package:cadenceiq/features/auth/forgot_password_screen.dart';
import 'package:cadenceiq/features/auth/oauth.dart';
import 'package:cadenceiq/features/auth/otp_screen.dart';
import 'package:cadenceiq/features/auth/reset_password_screen.dart';
import 'package:cadenceiq/features/profile/update_profile_screen.dart';
import 'package:cadenceiq/features/settings/strava_connect.dart';
import 'package:cadenceiq/features/activities/activities_list_screen.dart';
import 'package:cadenceiq/features/activities/activity_detail_screen.dart';
import 'package:cadenceiq/features/auth/login_screen.dart';
import 'package:cadenceiq/features/auth/signup_screen.dart';
import 'package:cadenceiq/features/dashboard/dashboard_screen.dart';
import 'package:cadenceiq/features/goals/create_goal_screen.dart';
import 'package:cadenceiq/features/goals/goal_detail_screen.dart';
import 'package:cadenceiq/features/goals/goals_screen.dart';
import 'package:cadenceiq/features/onboarding/onboarding_screen.dart';
import 'package:cadenceiq/features/onboarding/splash_screen.dart';
import 'package:cadenceiq/features/profile/profile_screen.dart';
import 'package:cadenceiq/features/settings/settings_screen.dart';
import 'package:cadenceiq/features/shell/main_shell.dart';
import 'package:cadenceiq/features/summaries/summary_detail_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

CustomTransitionPage<T> _slideUpPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: AppAnimations.normal,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return AppAnimations.fadeSlideIn(
        animation: animation,
        child: child,
      );
    },
  );
}

class AppRouter {
  static GoRouter create() {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RoutePaths.splash,
      routes: [
        GoRoute(
          path: RoutePaths.splash,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: RoutePaths.onboarding,
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: RoutePaths.login,
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: RoutePaths.signup,
          builder: (_, __) => const SignupScreen(),
        ),
        GoRoute(
          path: RoutePaths.otp,
          pageBuilder: (_, state) => _slideUpPage(
            key: state.pageKey,
            child: OTPScreen(args: state.extra as OtpScreenArgs),
          ),
        ),
        GoRoute(
          path: RoutePaths.forgotPassword,
          pageBuilder: (_, state) => _slideUpPage(
            key: state.pageKey,
            child: const ForgotPasswordScreen(),
          ),
        ),
        GoRoute(
          path: RoutePaths.resetPassword,
          pageBuilder: (_, state) => _slideUpPage(
            key: state.pageKey,
            child: ResetPasswordScreen(
              args: state.extra as ResetPasswordArgs,
            ),
          ),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.dashboard,
                  pageBuilder: (_, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const DashboardScreen(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.activities,
                  pageBuilder: (_, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const ActivitiesListScreen(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.goals,
                  pageBuilder: (_, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const GoalsScreen(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.settings,
                  pageBuilder: (_, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const SettingsScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: RoutePaths.connectStrava,
          pageBuilder: (_, state) => _slideUpPage(
            key: state.pageKey,
            child: StravaConnect(),
          ),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: RoutePaths.syncActivity,
          pageBuilder: (_, state) => _slideUpPage(
            key: state.pageKey,
            child: SyncStravaActivity(),
          ),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: '/activities/:id',
          pageBuilder: (_, state) => _slideUpPage(
            key: state.pageKey,
            child: ActivityDetailScreen(
              activityId: state.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: RoutePaths.createGoal,
          pageBuilder: (_, state) => _slideUpPage(
            key: state.pageKey,
            child: CreateGoalScreen(
              args: state.extra as CreateGoalScreenArgs,
            ),
          ),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: '/goals/:id',
          pageBuilder: (_, state) => _slideUpPage(
            key: state.pageKey,
            child: GoalDetailScreen(goalId: state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: '/summaries/:id',
          pageBuilder: (_, state) => _slideUpPage(
            key: state.pageKey,
            child: SummaryDetailScreen(
              summaryId: state.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: RoutePaths.profile,
          pageBuilder: (_, state) => _slideUpPage(
            key: state.pageKey,
            child: const ProfileScreen(),
          ),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: RoutePaths.updateProfile,
          pageBuilder: (_, state) => _slideUpPage(
            key: state.pageKey,
            child: const UpdateProfileScreen(),
          ),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: RoutePaths.oauth,
          pageBuilder: (_, state) => _slideUpPage(
            key: state.pageKey,
            child: OAuthResultScreen(
              success: state.uri.queryParameters['success'] == 'true',
            ),
          ),
        ),
      ],
    );
  }
}
