import 'package:cadenceiq/core/constants/app_strings.dart';
import 'package:cadenceiq/core/constants/route_paths.dart';
import 'package:cadenceiq/core/theme/app_colors.dart';
import 'package:cadenceiq/core/theme/app_spacing.dart';
import 'package:cadenceiq/core/utils/responsive.dart';
import 'package:cadenceiq/core/utils/snackbar.dart';
import 'package:cadenceiq/core/widgets/cadence_app_bar.dart';
import 'package:cadenceiq/core/widgets/primary_button.dart';
import 'package:cadenceiq/core/widgets/safe_page.dart';
import 'package:cadenceiq/core/widgets/text_form_field.dart';
import 'package:cadenceiq/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ResetPasswordArgs {
  const ResetPasswordArgs({required this.email, required this.otp});

  final String email;
  final String otp;
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.args});

  final ResetPasswordArgs args;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late AuthProvider auth;
  String password = '';
  String confirmPassword = '';

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    auth.clearErrors();
    final res = await auth.resetPassword(password: password);

    if (!mounted) return;

    if (res.response != null) {
      AppSnackbar.show(
        context,
        message: 'Password reset successfully. Please log in.',
        status: SnackbarStatus.success,
      );
      context.go(RoutePaths.login);
      return;
    }

    if (auth.errorMessage != null) {
      AppSnackbar.show(
        context,
        message: auth.errorMessage!,
        status: SnackbarStatus.error,
      );
    }
  }

  @override
  void initState() {
    auth = context.read<AuthProvider>();
    auth.clearErrors();
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
                    AppStrings.resetPasswordTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new password for ${widget.args.email}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextFormField(
                    label: AppStrings.newPassword,
                    initialValue: password,
                    onChanged: (value) => setState(() {
                      password = value;
                    }),
                    prefixIcon: const Icon(Icons.lock_outline),
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
                    prefixIcon: const Icon(Icons.lock_outline),
                    keyboardType: TextInputType.visiblePassword,
                    validator: (v) => v == null || v != password
                        ? 'Passwords do not match'
                        : null,
                    obsecureText: true,
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
                    label: AppStrings.resetPassword,
                    isLoading: auth.state == AuthState.loading,
                    onPressed: _resetPassword,
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
