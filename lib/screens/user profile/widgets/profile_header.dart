import 'package:flutter/material.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_theme_colors.dart';

class ProfileHeader extends StatelessWidget {
  final bool fromDashboard;
  final double screenWidth;
  final AppThemeColors colors;
  final VoidCallback? onLogout; // optional callback

  const ProfileHeader({
    super.key,
    required this.fromDashboard,
    required this.screenWidth,
    required this.colors,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fromDashboard ? "Profile Details" : "Review Your Profile",
                style: AppTypography.heading1(context).copyWith(
                  color: colors.primaryColor,
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                fromDashboard
                    ? "View and edit your personal details."
                    : "Verify your personal information before continuing.",
                style: AppTypography.caption(context).copyWith(
                  color: colors.textSecondary,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ],
          ),
        ),

        // Show logout button only when accessed from dashboard
        if (fromDashboard)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4),
            child: IconButton(
              tooltip: 'Logout',
              onPressed: onLogout,
              icon: Icon(
                Icons.logout_rounded,
                color: colors.primaryColor,
                size: screenWidth * 0.07,
              ),
            ),
          ),
      ],
    );
  }
}
