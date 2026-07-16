import 'package:cadenceiq_app/core/components/text_form_field.dart';
import 'package:cadenceiq_app/features/auth/otp_screen.dart';
import 'package:cadenceiq_app/store/store.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq_app/core/constants/app_strings.dart';
import 'package:cadenceiq_app/core/constants/route_paths.dart';
import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/core/widgets/primary_button.dart';
import 'package:cadenceiq_app/core/widgets/safe_page.dart';
import 'package:cadenceiq_app/providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.sendOtp(email: email, reason: OtpReason.registration);
    if (auth.isAuthenticated && mounted) {
      context.push(
        RoutePaths.otp,
        extra: OtpScreenArgs(
          onVerify: _signup,
          email: email,
          reason: OtpReason.registration,
        ),
      );
    }
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final res = await auth.signup(name: name, email: email, password: password);
    if (auth.isAuthenticated) {
      final accessToken = res.response['accessToken'];
      final refreshToken = res.response['refreshToken'];
      await TokenStorage.save(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      if (mounted) context.go(RoutePaths.dashboard);
    }
  }

  void navigateToLogin() {
    final auth = context.read<AuthProvider>();
    auth.clearErrors();
    context.go(RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
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
                  Text(
                    'Create account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your AI-powered training journey',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextFormField(
                    label: AppStrings.name,
                    initialValue: name,
                    onChanged: (value) => setState(() {
                      name = value;
                    }),
                    prefixIcon: Icon(Icons.person_outline),
                    keyboardType: TextInputType.name,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter your name' : null,
                  ),
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
                  CustomTextFormField(
                    label: AppStrings.confirmPassword,
                    initialValue: confirmPassword,
                    onChanged: (value) => setState(() {
                      confirmPassword = value;
                    }),
                    prefixIcon: Icon(Icons.lock_outline),
                    keyboardType: TextInputType.visiblePassword,
                    validator: (v) => v == null || v != password
                        ? 'Passwords do not match'
                        : null,
                    obsecureText: true,
                  ),
                  if (auth.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      auth.errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: AppStrings.signup,
                    isLoading: auth.state == AuthState.loading,
                    onPressed: _verify,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.haveAccount),
                      TextButton(
                        onPressed: navigateToLogin,
                        child: const Text(AppStrings.login),
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
