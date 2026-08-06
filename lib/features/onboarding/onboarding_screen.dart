import 'package:cadenceiq/core/assets/assets.dart';
import 'package:cadenceiq/core/widgets/loading.dart';
import 'package:cadenceiq/core/widgets/safe_page.dart';
import 'package:cadenceiq/store/store.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cadenceiq/core/constants/app_strings.dart';
import 'package:cadenceiq/core/constants/route_paths.dart';
import 'package:cadenceiq/core/theme/app_colors.dart';
import 'package:cadenceiq/core/theme/app_spacing.dart';
import 'package:cadenceiq/core/widgets/primary_button.dart';
import 'package:cadenceiq/models/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  bool _imagesReady = false;

  static final _pages = [
    OnboardingPageData(
      title: AppStrings.onboardingTitle1,
      subtitle: AppStrings.onboardingSubtitle1,
      image: AppImages.onboarding_1,
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle2,
      subtitle: AppStrings.onboardingSubtitle2,
      image: AppImages.onboarding_2,
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle3,
      subtitle: AppStrings.onboardingSubtitle3,
      image: AppImages.onboarding_3,
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle4,
      subtitle: AppStrings.onboardingSubtitle4,
      image: AppImages.onboarding_4,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_imagesReady) return;
    _precacheAllImages();
  }

  Future<void> _precacheAllImages() async {
    await Future.wait(
      _pages.map((page) => precacheImage(AssetImage(page.image), context)),
    );
    if (mounted) setState(() => _imagesReady = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await LocalStorage.setOnboardingCompleted();
    if (mounted) context.go(RoutePaths.login);
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_imagesReady
          ? AppLoading(label: "Getting started...")
          : Stack(
              alignment: Alignment.center,
              children: [
                PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    for (final page in _pages) _OnboardingPage(data: page),
                  ],
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: SafePage(
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.darkTextPrimary,
                      ),
                      child: const Text(AppStrings.skip),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (i) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                            ),
                            width: _currentPage == i ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == i
                                  ? AppColors.primary
                                  : AppColors.borderOf(context),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.xs,
                              ),
                            ),
                          );
                        }),
                      ),
                      SafeArea(
                        minimum: const EdgeInsets.all(AppSpacing.lg),
                        top: false,
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
              ],
            ),
    );
  }
}

class _OnboardingPage extends StatefulWidget {
  const _OnboardingPage({required this.data});
  final OnboardingPageData data;

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Size size = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Image.asset(
            widget.data.image,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            gaplessPlayback: true,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.2, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.87),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: size.height * 0.2,
          child: SizedBox(
            width: size.width * 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xl,
              children: [
                Text(
                  widget.data.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.darkTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.data.subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.darkTextPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
