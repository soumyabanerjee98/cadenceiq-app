import 'dart:io';

import 'package:cadenceiq/core/constants/route_paths.dart';
import 'package:cadenceiq/core/widgets/number_picker.dart';
import 'package:cadenceiq/core/widgets/text_form_field.dart';
import 'package:cadenceiq/core/theme/app_colors.dart';
import 'package:cadenceiq/core/utils/mediapicker.dart';
import 'package:cadenceiq/core/utils/responsive.dart';
import 'package:cadenceiq/core/utils/snackbar.dart';
import 'package:cadenceiq/core/widgets/cadence_app_bar.dart';
import 'package:cadenceiq/core/widgets/primary_button.dart';
import 'package:cadenceiq/core/widgets/safe_page.dart';
import 'package:cadenceiq/features/auth/otp_screen.dart';
import 'package:cadenceiq/features/auth/reset_password_screen.dart';
import 'package:cadenceiq/providers/auth_provider.dart';
import 'package:cadenceiq/providers/dashboard_provider.dart';
import 'package:cadenceiq/services/repo/auth_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late DashboardProvider dashboard;
  late AuthProvider auth;
  final AuthRepository _repo = AuthRepository();
  final _formKey = GlobalKey<FormState>();

  String? name;
  int? age;
  String? existingImage;
  File? image;

  bool loading = false;
  bool resetLoading = false;

  Future<void> selectImage() async {
    final file = await MediaPicker.showImagePicker(context);

    if (file == null) return;

    setState(() {
      image = file;
    });
  }

  void _removePhoto() async {
    setState(() {
      existingImage = null;
      image = null;
    });
  }

  Future<void> _updateProfile() async {
    setState(() {
      loading = true;
    });
    Map<String, dynamic> payload = {"name": name, "age": age};
    if (dashboard.user?.avatarUrl != null) {
      if (existingImage == null && image == null) {
        payload["removeImage"] = true;
      }
    }
    if (image != null) {
      final multiPartFile = await MultipartFile.fromFile(
        image!.path,
        filename: image!.path.split('/').last,
      );
      payload["image"] = multiPartFile;
    }
    FormData formData = FormData.fromMap(payload);
    final res = await _repo.updateProfile(formData);
    if (res.response != null) {
      await dashboard.refresh();
      if (mounted) {
        AppSnackbar.show(
          context,
          message: "Profile updated successfully!",
          status: SnackbarStatus.success,
        );
        context.pop();
      }
    } else if (mounted && res.error?.errorMessage != null) {
      AppSnackbar.show(
        context,
        message: res.error!.errorMessage,
        status: SnackbarStatus.error,
      );
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _startResetPassword() async {
    final email = dashboard.user?.email.trim();
    if (email == null || email.isEmpty) {
      AppSnackbar.show(
        context,
        message: 'Email not available on your profile.',
        status: SnackbarStatus.error,
      );
      return;
    }

    auth.clearErrors();
    setState(() => resetLoading = true);

    final res = await auth.sendOtp(
      email: email,
      reason: OtpReason.resetPassword,
    );

    if (!mounted) return;
    setState(() => resetLoading = false);

    if (res.response != null) {
      context.push(
        RoutePaths.otp,
        extra: OtpScreenArgs(
          email: email,
          reason: OtpReason.resetPassword,
          onVerify: (otp) {
            context.push(
              RoutePaths.resetPassword,
              extra: ResetPasswordArgs(
                email: email,
                otp: otp,
                fromProfile: true,
              ),
            );
          },
        ),
      );
      return;
    }

    AppSnackbar.show(
      context,
      message: auth.errorMessage ?? 'Failed to send OTP. Please try again.',
      status: SnackbarStatus.error,
    );
  }

  @override
  void initState() {
    dashboard = context.read<DashboardProvider>();
    auth = context.read<AuthProvider>();
    setState(() {
      name = dashboard.user?.name;
      age = dashboard.user?.age;
      existingImage = dashboard.user?.avatarUrl;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dashboard = context.watch<DashboardProvider>();
    auth = context.watch<AuthProvider>();
    final padding = Responsive.horizontalPadding(context);
    return Scaffold(
      appBar: CadenceAppBar(showBack: true, title: 'Update Profile'),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: PrimaryButton(
          label: "Update",
          isLoading: loading,
          onPressed: _updateProfile,
        ),
      ),
      body: SafePage(
        child: ListView(
          padding: EdgeInsets.all(padding),
          children: [
            Center(
              child: Stack(
                children: [
                  Hero(
                    tag: 'profile-avatar',
                    child: CircleAvatar(
                      radius: 72,
                      backgroundColor: AppColors.primary,
                      child: ClipOval(
                        child: image != null
                            ? Image.file(
                                image!,
                                width: 144,
                                height: 144,
                                fit: BoxFit.cover,
                              )
                            : (existingImage?.isNotEmpty ?? false)
                            ? Image.network(
                                existingImage!,
                                width: 144,
                                height: 144,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }

                                      return Text(
                                        dashboard.user?.initials ?? "",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 36,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      );
                                    },
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    dashboard.user?.initials ?? "",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  dashboard.user?.initials ?? "",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: selectImage,
                      padding: EdgeInsets.zero,
                      icon: CircleAvatar(
                        child: Icon(Icons.camera_alt_outlined),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (existingImage != null || image != null)
              Column(
                children: [
                  TextButton(
                    onPressed: _removePhoto,
                    child: Text("Remove Photo"),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextFormField(
                    label: "Name",
                    initialValue: name ?? "",
                    onChanged: (value) => setState(() {
                      name = value;
                    }),
                    prefixIcon: Icon(Icons.person_outline),
                    keyboardType: TextInputType.name,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter your name' : null,
                  ),
                  CustomNumberPicker(
                    label: "Age",
                    min: 18,
                    max: 100,
                    initialValue: age,
                    prefixIcon: Icon(Icons.cake_outlined),
                    suffixText: "years",
                    onChanged: (value) => setState(() {
                      age = value;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.lock_reset_outlined,
                  color: AppColors.textSecondaryOf(context),
                ),
                title: const Text('Reset Password'),
                subtitle: Text(
                  'Verify with OTP sent to your email',
                  style: TextStyle(
                    color: AppColors.textSecondaryOf(context),
                    fontSize: 12,
                  ),
                ),
                trailing: resetLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right, size: 20),
                onTap: resetLoading ? null : _startResetPassword,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
