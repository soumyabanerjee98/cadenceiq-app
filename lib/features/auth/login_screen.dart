import 'package:cadenceiq/core/widgets/text_form_field.dart';
import 'package:cadenceiq/store/store.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq/core/constants/app_strings.dart';
import 'package:cadenceiq/core/constants/route_paths.dart';
import 'package:cadenceiq/core/theme/app_colors.dart';
import 'package:cadenceiq/core/utils/responsive.dart';
import 'package:cadenceiq/core/utils/snackbar.dart';
import 'package:cadenceiq/core/widgets/cadence_app_bar.dart';
import 'package:cadenceiq/core/widgets/primary_button.dart';
import 'package:cadenceiq/core/theme/app_spacing.dart';
import 'package:cadenceiq/core/widgets/safe_page.dart';
import 'package:cadenceiq/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  late AuthProvider auth;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    auth.clearErrors();
    final res = await auth.login(email, password);
    if (!mounted) return;
    if (auth.isAuthenticated) {
      final accessToken = res.response['accessToken'];
      final refreshToken = res.response['refreshToken'];
      await TokenStorage.save(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      if (mounted) context.go(RoutePaths.dashboard);
    } else {
      AppSnackbar.show(
        context,
        message: auth.errorMessage ?? 'Login failed. Please try again.',
        status: SnackbarStatus.error,
      );
    }
  }

  void navigateToSignup() {
    auth.clearErrors();
    context.go(RoutePaths.signup);
  }

  @override
  void initState() {
    auth = context.read<AuthProvider>();
    auth.cleanUpProviders(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    auth = context.watch<AuthProvider>();
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      body: SafePage(
        child: Responsive.centeredContent(
          context: context,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  const Center(child: CadenceLogo(size: 72)),
                  const SizedBox(height: 24),
                  Text.rich(
                    TextSpan(
                      text: 'Welcome to ',
                      children: [
                        TextSpan(
                          text: "CadenceIQ",
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue your training',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryOf(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CustomTextFormField(
                    label: AppStrings.email,
                    initialValue: email,
                    onChanged: (value) => setState(() {
                      email = value;
                    }),
                    prefixIcon: Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || !v.contains('@')
                        ? 'Enter a valid email'
                        : null,
                  ),
                  CustomTextFormField(
                    label: AppStrings.password,
                    initialValue: password,
                    onChanged: (value) => setState(() {
                      password = value;
                    }),
                    prefixIcon: Icon(Icons.lock_outline),
                    keyboardType: TextInputType.visiblePassword,
                    validator: (v) => v == null || v.length < 6
                        ? 'Password must be 6+ characters'
                        : null,
                    obsecureText: true,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        auth.clearErrors();
                        context.push(RoutePaths.forgotPassword);
                      },
                      child: const Text(AppStrings.forgotPassword),
                    ),
                  ),
                  PrimaryButton(
                    label: AppStrings.login,
                    isLoading: auth.state == AuthState.loading,
                    onPressed: _login,
                  ),
                  // const SizedBox(height: 24),
                  // Row(
                  //   children: [
                  //     const Expanded(child: Divider()),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 16),
                  //       child: Text(
                  //         AppStrings.continueWith,
                  //         style: Theme.of(context).textTheme.bodySmall,
                  //       ),
                  //     ),
                  //     const Expanded(child: Divider()),
                  //   ],
                  // ),
                  // const SizedBox(height: 16),
                  // SocialAuthButton(
                  //   label: 'Continue with Google',
                  //   icon: AppImages.googleIcon,
                  //   onPressed: () {},
                  // ),
                  // if (Platform.isIOS == true) ...[
                  //   const SizedBox(height: 10),
                  //   SocialAuthButton(
                  //     label: 'Continue with Apple',
                  //     icon: ThemeMode.system.name == 'light'
                  //         ? AppImages.appleIconDark
                  //         : AppImages.appleIcon,
                  //     onPressed: () {},
                  //   ),
                  // ],
                  // const SizedBox(height: 10),
                  // SocialAuthButton(
                  //   label: 'Continue with Facebook',
                  //   icon: AppImages.facebookIcon,
                  //   onPressed: () {},
                  // ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.noAccount),
                      TextButton(
                        onPressed: navigateToSignup,
                        child: const Text(AppStrings.signup),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
