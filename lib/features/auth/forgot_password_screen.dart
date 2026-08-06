import 'package:cadenceiq/core/constants/app_strings.dart';
import 'package:cadenceiq/core/constants/route_paths.dart';
import 'package:cadenceiq/core/theme/app_colors.dart';
import 'package:cadenceiq/core/theme/app_spacing.dart';
import 'package:cadenceiq/core/utils/responsive.dart';
import 'package:cadenceiq/core/widgets/cadence_app_bar.dart';
import 'package:cadenceiq/core/widgets/primary_button.dart';
import 'package:cadenceiq/core/widgets/safe_page.dart';
import 'package:cadenceiq/core/widgets/text_form_field.dart';
import 'package:cadenceiq/features/auth/otp_screen.dart';
import 'package:cadenceiq/features/auth/reset_password_screen.dart';
import 'package:cadenceiq/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late AuthProvider auth;
  String email = '';

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    auth.clearErrors();
    final res = await auth.sendOtp(
      email: email.trim(),
      reason: OtpReason.forgotPassword,
    );

    if (!mounted) return;

    if (res.response != null) {
      context.push(
        RoutePaths.otp,
        extra: OtpScreenArgs(
          email: email.trim(),
          reason: OtpReason.forgotPassword,
          onVerify: (otp) {
            context.push(
              RoutePaths.resetPassword,
              extra: ResetPasswordArgs(email: email.trim(), otp: otp),
            );
          },
        ),
      );
    }
  }

  void _backToLogin() {
    auth.clearErrors();
    context.go(RoutePaths.login);
  }

  @override
  void initState() {
    auth = context.read<AuthProvider>();
    auth.clearErrors();
    auth.reset();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    auth = context.watch<AuthProvider>();
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: const CadenceAppBar(showBack: true),
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
                  const SizedBox(height: AppSpacing.lg),
                  const Center(child: CadenceLogo(size: 72)),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    AppStrings.forgotPasswordTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email and we will send a one-time password to reset your account.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextFormField(
                    label: AppStrings.email,
                    initialValue: email,
                    onChanged: (value) => setState(() {
                      email = value;
                    }),
                    prefixIcon: const Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || !v.contains('@')
                        ? 'Enter a valid email'
                        : null,
                  ),
                  if (auth.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      auth.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: AppStrings.sendOtp,
                    isLoading: auth.state == AuthState.loading,
                    onPressed: _sendOtp,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _backToLogin,
                    child: const Text(AppStrings.backToLogin),
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
