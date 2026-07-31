import 'package:cadenceiq/core/assets/assets.dart';
import 'package:cadenceiq/core/theme/app_colors.dart';
import 'package:cadenceiq/core/utils/responsive.dart';
import 'package:cadenceiq/core/widgets/cadence_app_bar.dart';
import 'package:cadenceiq/core/widgets/primary_button.dart';
import 'package:cadenceiq/core/widgets/safe_page.dart';
import 'package:cadenceiq/providers/dashboard_provider.dart';
import 'package:cadenceiq/providers/settings_provider.dart';
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
  late DashboardProvider profile;

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
    setState(() {
      loading = true;
    });
    final res = await settings.disconnectStrava();
    if (res == true) {
      await profile.refresh();
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _action() async {
    if (profile.user?.stravaConnected == true) {
      _disconnect();
    } else {
      _connect();
    }
  }

  @override
  void initState() {
    profile = context.read<DashboardProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final size = MediaQuery.of(context).size;
    profile = context.watch<DashboardProvider>();
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
