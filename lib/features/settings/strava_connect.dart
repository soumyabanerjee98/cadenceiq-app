import 'package:cadenceiq_app/core/assets/assets.dart';
import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/core/widgets/cadence_app_bar.dart';
import 'package:cadenceiq_app/core/widgets/primary_button.dart';
import 'package:cadenceiq_app/core/widgets/safe_page.dart';
import 'package:cadenceiq_app/providers/dashboard_provider.dart';
import 'package:cadenceiq_app/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class StravaConnect extends StatefulWidget {
  const StravaConnect({super.key});

  @override
  State<StravaConnect> createState() => _StravaConnectState();
}

class _StravaConnectState extends State<StravaConnect> {
  bool loading = false;

  Future<void> _connect() async {
    final settings = context.read<SettingsProvider>();
    setState(() {
      loading = true;
    });
    await settings.connectStrava();
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _disconnect() async {
    final settings = context.read<SettingsProvider>();
    final dashboard = context.read<DashboardProvider>();
    setState(() {
      loading = true;
    });
    final res = await settings.disconnectStrava();
    if (res == true) {
      await dashboard.refresh();
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _action() async {
    final profile = context.read<DashboardProvider>();
    if (profile.user?.stravaConnected == true) {
      _disconnect();
    } else {
      _connect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final size = MediaQuery.of(context).size;
    final profile = context.watch<DashboardProvider>();
    return Scaffold(
      appBar: CadenceAppBar(showBack: true, title: "Strava"),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.all(16),
        child: PrimaryButton(
          label: profile.user?.stravaConnected == true
              ? "Disconnect"
              : "Connect",
          isLoading: loading,
          onPressed: _action,
        ),
      ),
      body: SafePage(
        child: ListView(
          padding: EdgeInsets.all(padding),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.1),
              child: Center(
                child: Column(
                  children: [
                    SvgPicture.asset(AppImages.stravaIcon),
                    SvgPicture.asset(AppImages.stravaIconText),
                  ],
                ),
              ),
            ),
            Text.rich(
              TextSpan(
                text:
                    "Connect your Strava account to automatically sync your cycling activities with ",
                children: [
                  TextSpan(
                    text: "CadenceIQ",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text:
                        ".\n\nYour rides, distance, duration, heart rate, elevation, and other performance metrics are securely imported to generate personalized training insights, track progress toward your goals, and help you train smarter. You stay in control and can sync new activities whenever you choose.",
                  ),
                ],
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
