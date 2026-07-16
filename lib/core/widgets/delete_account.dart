import 'package:cadenceiq_app/core/constants/app_strings.dart';
import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/core/widgets/primary_button.dart';
import 'package:cadenceiq_app/core/widgets/text_form_field.dart';
import 'package:cadenceiq_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  String password = '';

  Future<void> _deleteAccount() async {
    final auth = context.read<AuthProvider>();
    auth.deleteAccount(password: password);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final padding = Responsive.horizontalPadding(context);
    return SafeArea(
      top: false,
      minimum: EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter Password',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter password for confirmation of account deletion',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
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
          if (auth.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              auth.errorMessage!,
              style: const TextStyle(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: "Delete Account",
            isLoading: auth.state == AuthState.loading,
            onPressed: _deleteAccount,
            danger: true,
            paddingDisable: true,
          ),
        ],
      ),
    );
  }
}
