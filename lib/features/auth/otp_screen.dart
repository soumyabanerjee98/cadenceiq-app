import 'dart:async';

import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/core/widgets/cadence_app_bar.dart';
import 'package:cadenceiq_app/core/widgets/otp_pin.dart';
import 'package:cadenceiq_app/core/widgets/primary_button.dart';
import 'package:cadenceiq_app/core/widgets/safe_page.dart';
import 'package:cadenceiq_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum OtpReason { registration, resetPassword, forgotPassword }

class OtpScreenArgs {
  const OtpScreenArgs({
    required this.onVerify,
    required this.email,
    required this.reason,
  });
  final String email;
  final OtpReason reason;
  final VoidCallback onVerify;
}

class OTPScreen extends StatefulWidget {
  final OtpScreenArgs args;
  const OTPScreen({super.key, required this.args});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  bool loading = false;
  String otp = '';

  Timer? _timer;
  late int _remaining;

  void _start() {
    _remaining = 60;

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining == 0) {
        timer.cancel();
        return;
      }
      if (mounted) {
        setState(() {
          _remaining--;
        });
      }
    });
  }

  String get _formattedTime {
    final minutes = (_remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remaining % 60).toString().padLeft(2, '0');

    return "$minutes:$seconds";
  }

  Future<void> _verify() async {
    setState(() {
      loading = true;
    });
    final auth = context.read<AuthProvider>();
    await auth.verifyOtp(email: widget.args.email, otp: otp);
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
    if (auth.isAuthenticated && mounted) {
      widget.args.onVerify();
    }
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    await auth.sendOtp(email: widget.args.email, reason: widget.args.reason);
    if (auth.isAuthenticated) {
      _start();
    }
  }

  @override
  void initState() {
    _start();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: CadenceAppBar(showBack: true),
      body: SafePage(
        child: Responsive.centeredContent(
          context: context,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Verify OTP',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verify the 4 digit OTP sent to ${widget.args.email}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                OTPField(
                  onComplete: (String val) {
                    setState(() {
                      otp = val;
                    });
                    _verify();
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _remaining > 0
                        ? Text("Resend OTP in $_formattedTime")
                        : TextButton(
                            onPressed: _resend,
                            child: Text("Resend OTP"),
                          ),
                  ],
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
                  label: "Verify",
                  isLoading: (auth.state == AuthState.loading) && loading,
                  onPressed: _verify,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
