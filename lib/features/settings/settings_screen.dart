import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq_app/core/constants/route_paths.dart';
import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/providers/auth_provider.dart';
import 'package:cadenceiq_app/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(padding, 16, padding, 32),
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Account'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'View and edit your profile',
            onTap: () => context.push(RoutePaths.profile),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            value: settings.pushNotifications,
            activeColor: AppColors.primary,
            onChanged: settings.setPushNotifications,
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            value: settings.emailNotifications,
            activeColor: AppColors.primary,
            onChanged: settings.setEmailNotifications,
          ),
          SwitchListTile(
            title: const Text('Training Reminders'),
            value: settings.trainingReminders,
            activeColor: AppColors.primary,
            onChanged: settings.setTrainingReminders,
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: settings.darkMode,
            activeColor: AppColors.primary,
            onChanged: settings.setDarkMode,
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Preferences'),
          SwitchListTile(
            title: const Text('Imperial Units'),
            subtitle: Text(settings.useImperial ? 'Miles, feet' : 'Kilometers, meters'),
            value: settings.useImperial,
            activeColor: AppColors.primary,
            onChanged: settings.setUseImperial,
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(settings.language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(context, settings),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Privacy'),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.security,
            title: 'Data & Security',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Connected Services'),
          _SettingsTile(
            icon: Icons.link,
            title: 'Strava',
            subtitle: 'Not connected',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.watch,
            title: 'Garmin Connect',
            subtitle: 'Not connected',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.favorite_border,
            title: 'Wahoo',
            subtitle: 'Not connected',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About CadenceIQ',
            subtitle: 'Version 1.0.0',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go(RoutePaths.login);
            },
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text('Log Out', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Spanish', 'French', 'German']
              .map((lang) => ListTile(
                    title: Text(lang),
                    trailing: settings.language == lang
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      settings.setLanguage(lang);
                      Navigator.pop(ctx);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
