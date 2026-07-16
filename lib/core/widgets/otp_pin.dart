import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OTPField extends StatelessWidget {
  final void Function(String)? onComplete;
  const OTPField({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: AppTheme.isDarkMode(context)
            ? AppColors.darkSurface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary),
      borderRadius: BorderRadius.circular(20),
    );

    return Pinput(
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      onCompleted: onComplete,
    );
  }
}
