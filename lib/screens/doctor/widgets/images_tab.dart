import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/controllers/doctor_patient_detail_controller.dart';
import 'package:rudhirakshapp/data/models/doctor_models.dart';

class ImagesTab extends StatelessWidget {
  final DoctorPatientDetailController controller;

  const ImagesTab({super.key, required this.controller});

  void _openFullScreen(BuildContext context, PatientImage img) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(0),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: img.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, _) =>
                      const Center(child: CircularProgressIndicator(color: Colors.white)),
                  errorWidget: (_, _, _) =>
                      const Icon(Icons.broken_image, color: Colors.white, size: 64),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return Obx(() {
      if (controller.images.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(SolarLinearIcons.gallery, size: 48, color: colors.textSecondary),
              const SizedBox(height: 12),
              Text(
                'No images yet',
                style: TextStyle(color: colors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchAll(),
        color: colors.primaryColor,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: controller.images.length,
          itemBuilder: (context, index) {
            final img = controller.images[index];
            return GestureDetector(
              onTap: () => _openFullScreen(context, img),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(12)),
                        child: CachedNetworkImage(
                          imageUrl: img.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                            color: colors.backgroundColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primaryColor,
                              ),
                            ),
                          ),
                          errorWidget: (_, _, _) => Container(
                            color: colors.backgroundColor,
                            child: Icon(Icons.broken_image,
                                color: colors.textSecondary, size: 32),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (img.caption != null && img.caption!.isNotEmpty)
                            Text(
                              img.caption!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          Text(
                            img.formattedDate,
                            style: TextStyle(color: colors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
