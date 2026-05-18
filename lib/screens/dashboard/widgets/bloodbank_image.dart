import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';

class BloodBankImage extends StatelessWidget {
  final String imagePath;
  final Color backgroundColor;
  final double radius;
  final VoidCallback? onTap;

  const BloodBankImage({
    super.key,
    required this.imagePath,
    required this.backgroundColor,
    this.radius = 50, // Default bigger size
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          child: ClipOval(
            child:
                imagePath.isNotEmpty
                    ? CachedNetworkImage(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                      width: radius * 2,
                      height: radius * 2,
                      placeholder:
                          (context, url) => Center(
                            child: SizedBox(
                              width: radius / 2,
                              height: radius / 2,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Icon(
                            Icons.apartment,
                            size: radius,
                            color: AppColors.lightPrimary,
                          ),
                    )
                    : Icon(
                      Icons.apartment,
                      size: radius,
                      color: AppColors.lightPrimary,
                    ),
          ),
        ),
      ),
    );
  }
}
