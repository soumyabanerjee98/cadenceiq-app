import 'package:cadenceiq_app/store/store.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cadenceiq_app/core/constants/app_strings.dart';
import 'package:cadenceiq_app/core/constants/route_paths.dart';
import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/widgets/primary_button.dart';
import 'package:cadenceiq_app/core/widgets/safe_page.dart';
import 'package:cadenceiq_app/models/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static final _pages = [
    OnboardingPageData(
      title: AppStrings.onboardingTitle1,
      subtitle: AppStrings.onboardingSubtitle1,
      icon: Icons.directions_bike,
      iconColor: AppColors.primary,
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle2,
      subtitle: AppStrings.onboardingSubtitle2,
      icon: Icons.analytics_outlined,
      iconColor: AppColors.info,
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle3,
      subtitle: AppStrings.onboardingSubtitle3,
      icon: Icons.calendar_month_outlined,
      iconColor: AppColors.success,
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle4,
      subtitle: AppStrings.onboardingSubtitle4,
      icon: Icons.trending_up,
      iconColor: AppColors.warning,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() async {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      await LocalStorage.setOnboardingCompleted();
      if (mounted) context.go(RoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafePage(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await LocalStorage.setOnboardingCompleted();
                  if (mounted) context.go(RoutePaths.login);
                },
                child: const Text(AppStrings.skip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppColors.primary
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                label: _currentPage == _pages.length - 1
                    ? AppStrings.getStarted
                    : AppStrings.next,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});
  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: data.iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 80, color: data.iconColor),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
