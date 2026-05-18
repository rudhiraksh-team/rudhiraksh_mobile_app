import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';

/// Shows a bottom sheet with View / Download actions for a remote file.
///
/// "View" opens the URL in an in-app browser view (good for previewing
/// PDFs and images without leaving the app). "Download" hands off to
/// the external browser, which downloads the file to the device.
class FileViewerHelper {
  static Future<void> showViewerSheet(
    BuildContext context, {
    required String? url,
    String? fileName,
  }) async {
    if (url == null || url.isEmpty) {
      Get.snackbar('Unavailable', 'No file is attached to this entry.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      Get.snackbar('Invalid link', 'The file URL appears to be malformed.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final colors = AppThemeColors.of(context);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (fileName != null && fileName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                Text(
                  'Choose how to open this file',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                _SheetAction(
                  icon: SolarLinearIcons.eye,
                  label: 'View',
                  description: 'Preview inside the app',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _open(uri, LaunchMode.inAppBrowserView);
                  },
                ),
                const SizedBox(height: 8),
                _SheetAction(
                  icon: SolarLinearIcons.downloadMinimalistic,
                  label: 'Download',
                  description: 'Open in browser to save the file',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _open(uri, LaunchMode.externalApplication);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> _open(Uri uri, LaunchMode mode) async {
    try {
      final launched = await launchUrl(uri, mode: mode);
      if (!launched) {
        Get.snackbar('Couldn\'t open file',
            'No app on this device can handle the link.',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Couldn\'t open file', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _SheetAction({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colors.primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(SolarLinearIcons.altArrowRight,
                color: colors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
