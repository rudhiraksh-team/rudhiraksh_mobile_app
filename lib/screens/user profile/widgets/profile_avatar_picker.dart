import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/controllers/global_profile_controller.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/data/services/profile_photo_service.dart';

/// Round avatar with a small camera badge. Tap to upload a new photo from
/// camera or gallery. Shows initials when no photo is set.
class ProfileAvatarPicker extends StatefulWidget {
  final double radius;
  final String initials;

  const ProfileAvatarPicker({
    super.key,
    required this.initials,
    this.radius = 50,
  });

  @override
  State<ProfileAvatarPicker> createState() => _ProfileAvatarPickerState();
}

class _ProfileAvatarPickerState extends State<ProfileAvatarPicker> {
  bool _uploading = false;

  Future<void> _pick(BuildContext context) async {
    if (_uploading) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppThemeColors.of(context).surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        final colors = AppThemeColors.of(sheetCtx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(SolarLinearIcons.camera, color: colors.primaryColor),
                  title: const Text('Take photo'),
                  onTap: () => Navigator.pop(sheetCtx, ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(SolarLinearIcons.gallery, color: colors.primaryColor),
                  title: const Text('Choose from gallery'),
                  onTap: () => Navigator.pop(sheetCtx, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    final result = await ProfilePhotoService.uploadAndPersist(File(picked.path));
    if (!mounted) return;
    setState(() => _uploading = false);

    if (result.success && result.url != null) {
      Get.find<GlobalProfileController>().setProfilePhotoUrl(result.url!);
      Get.snackbar(
        'Profile',
        'Photo updated',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Profile',
        result.errorMessage ?? 'Could not update photo',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final size = widget.radius * 2;

    return GestureDetector(
      onTap: () => _pick(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Obx(() {
            // Reading profilePhotoUrl touches profileData['data'] internally,
            // which is enough to subscribe Obx to controller updates.
            final url = Get.find<GlobalProfileController>().profilePhotoUrl;
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primaryColor,
              ),
              clipBehavior: Clip.antiAlias,
              child: url != null
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => _initials(),
                    )
                  : _initials(),
            );
          }),
          if (_uploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          // Camera badge
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: colors.backgroundColor, width: 2.5),
              ),
              child: const Icon(
                SolarLinearIcons.camera,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initials() {
    return Center(
      child: Text(
        widget.initials,
        style: TextStyle(
          fontSize: widget.radius * 0.64,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
