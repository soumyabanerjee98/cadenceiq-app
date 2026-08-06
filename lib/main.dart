import 'package:cadenceiq/core/navigation/deep_link.dart';
import 'package:cadenceiq/core/network/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq/core/constants/app_strings.dart';
import 'package:cadenceiq/core/navigation/app_router.dart';
import 'package:cadenceiq/core/theme/app_theme.dart';
import 'package:cadenceiq/providers/activity_provider.dart';
import 'package:cadenceiq/providers/auth_provider.dart';
import 'package:cadenceiq/providers/dashboard_provider.dart';
import 'package:cadenceiq/providers/goal_provider.dart';
import 'package:cadenceiq/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  DioClient.instance.initialize();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  final GoRouter router = AppRouter.create();
  final deepLinkService = DeepLinkService(router);
  await deepLinkService.initialize();
  runApp(CadenceIQApp(router: router));
}

class CadenceIQApp extends StatelessWidget {
  final GoRouter? router;
  const CadenceIQApp({super.key, this.router});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
          ChangeNotifierProvider(create: (_) => ActivityProvider()),
          ChangeNotifierProvider(create: (_) => GoalProvider()),
        ],
        child: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return MaterialApp.router(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: ThemeMode.system,
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
