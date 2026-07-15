import 'dart:io';

import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaPicker {
  MediaPicker._();

  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImageFromGallery() async {
    try {
      final status = await Permission.photos.status;
      if (status == PermissionStatus.permanentlyDenied) {
        openAppSettings();
        return null;
      }
      if (status == PermissionStatus.denied) {
        final newStatus = await Permission.photos.request();
        if (newStatus == PermissionStatus.denied ||
            newStatus == PermissionStatus.permanentlyDenied) {
          return null;
        }
      }
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2048,
      );

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      return null;
    }
  }

  static Future<File?> pickImageFromCamera() async {
    try {
      final status = await Permission.camera.status;
      if (status == PermissionStatus.permanentlyDenied) {
        openAppSettings();
        return null;
      }
      if (status == PermissionStatus.denied) {
        final newStatus = await Permission.camera.request();
        if (newStatus == PermissionStatus.denied ||
            newStatus == PermissionStatus.permanentlyDenied) {
          return null;
        }
      }
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 2048,
      );

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      return null;
    }
  }

  static Future<File?> pickVideo() async {
    try {
      final status = await Permission.videos.status;
      if (status == PermissionStatus.permanentlyDenied) {
        openAppSettings();
        return null;
      }
      if (status == PermissionStatus.denied) {
        final newStatus = await Permission.videos.request();
        if (newStatus == PermissionStatus.denied ||
            newStatus == PermissionStatus.permanentlyDenied) {
          return null;
        }
      }
      final video = await _picker.pickVideo(source: ImageSource.gallery);

      if (video == null) return null;

      return File(video.path);
    } catch (e) {
      return null;
    }
  }

  static Future<File?> showImagePicker(BuildContext context) async {
    return await showModalBottomSheet<File>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          top: false,
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.primary,
                ),
                title: const Text("Camera"),
                onTap: () async {
                  final file = await pickImageFromCamera();
                  if (context.mounted) Navigator.pop(context, file);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: const Text("Gallery"),
                onTap: () async {
                  final file = await pickImageFromGallery();
                  if (context.mounted) Navigator.pop(context, file);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
