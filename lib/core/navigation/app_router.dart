import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cadenceiq_app/core/constants/route_paths.dart';
import 'package:cadenceiq_app/features/activities/activities_list_screen.dart';
import 'package:cadenceiq_app/features/activities/activity_detail_screen.dart';
import 'package:cadenceiq_app/features/auth/login_screen.dart';
import 'package:cadenceiq_app/features/auth/signup_screen.dart';
import 'package:cadenceiq_app/features/dashboard/dashboard_screen.dart';
import 'package:cadenceiq_app/features/goals/create_goal_screen.dart';
import 'package:cadenceiq_app/features/goals/goal_detail_screen.dart';
import 'package:cadenceiq_app/features/goals/goals_screen.dart';
import 'package:cadenceiq_app/features/onboarding/onboarding_screen.dart';
import 'package:cadenceiq_app/features/onboarding/splash_screen.dart';
import 'package:cadenceiq_app/features/profile/profile_screen.dart';
import 'package:cadenceiq_app/features/settings/settings_screen.dart';
import 'package:cadenceiq_app/features/shell/main_shell.dart';
import 'package:cadenceiq_app/features/summaries/summaries_list_screen.dart';
import 'package:cadenceiq_app/features/summaries/summary_detail_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter create() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
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
                  path: RoutePaths.summaries,
                  pageBuilder: (_, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const SummariesListScreen(),
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
          parentNavigatorKey: _rootNavigatorKey,
          path: '/activities/:id',
          builder: (_, state) => ActivityDetailScreen(
            activityId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/goals/:id',
          builder: (_, state) => GoalDetailScreen(
            goalId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: RoutePaths.createGoal,
          builder: (_, __) => const CreateGoalScreen(),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/summaries/:id',
          builder: (_, state) => SummaryDetailScreen(
            summaryId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: RoutePaths.profile,
          builder: (_, __) => const ProfileScreen(),
        ),
      ],
    );
  }
}
