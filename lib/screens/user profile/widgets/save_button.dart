import 'package:flutter/material.dart';
import 'package:rudhirakshapp/core/widgets/custom_elevated_button.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../controllers/profile_review_controller.dart';

class SaveButton extends StatelessWidget {
  final bool fromDashboard;
  final ProfileReviewController controller;
  final AppThemeColors colors;
  final double screenWidth;
  final double screenHeight;

  const SaveButton({
    super.key,
    required this.fromDashboard,
    required this.controller,
    required this.colors,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      label: fromDashboard ? "Save Changes" : "Continue",
      onPressed: () => controller.saveProfile(fromDashboard: fromDashboard),
    );
  }
}
