import 'package:flutter/material.dart';

/// Master color definitions - Rudhiraksh Red Healthcare Palette
/// PDF requirement: #F380B8, #E55466, #E03348, #C50018, #8E0006
class AppColors {
  /// Brand Colors (from PDF)
  static const Color brandPink = Color(0xFFF380B8);
  static const Color brandRose = Color(0xFFE55466);
  static const Color brandRed = Color(0xFFE03348);
  static const Color brandCrimson = Color(0xFFC50018);
  static const Color brandDarkRed = Color(0xFF8E0006);

  /// Common Status Colors
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFFF1744);
  static const Color darkError = Color(0xFFFF5252);
  static const Color info = Color(0xFF448AFF);
  static const Color upcoming = Color(0xFFFF6D00);
  static const Color alert = Color(0xFFFF3D00);
  static const Color white = Color(0xFFFFFFFF);

  /// Multi-Color Accent Palette
  static const Color teal = Color(0xFF00BFA5);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color amber = Color(0xFFFFB300);
  static const Color indigo = Color(0xFF536DFE);
  static const Color purple = Color(0xFF7C4DFF);
  static const Color cyan = Color(0xFF00BCD4);
  static const Color emerald = Color(0xFF10B981);
  static const Color rose = Color(0xFFF43F5E);
  static const Color sky = Color(0xFF0EA5E9);
  static const Color orange = Color(0xFFF97316);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC4899);

  /// Section-Specific Colors
  static const Color profileAccent = Color(0xFFC50018);   // Brand crimson
  static const Color calendarAccent = Color(0xFFE03348);   // Brand red
  static const Color historyAccent = Color(0xFF8E0006);    // Brand dark red
  static const Color notifAccent = Color(0xFFE55466);      // Brand rose
  static const Color transfusionAccent = Color(0xFFC50018); // Brand crimson

  /// Light Theme Colors
  static const Color lightPrimary = Color(0xFFC50018);     // Brand crimson
  static const Color lightSecondary = Color(0xFFE03348);   // Brand red
  static const Color lightTertiary = Color(0xFFE55466);    // Brand rose
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightNotificationCard = Color(0xFFFFF7ED);
  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color lightBorder = Color(0xFFE2E8F0);

  /// Dark Theme Colors
  static const Color darkPrimary = Color(0xFFE55466);      // Brand rose (lighter for dark bg)
  static const Color darkSecondary = Color(0xFFF380B8);    // Brand pink
  static const Color darkTertiary = Color(0xFFE03348);     // Brand red
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkNotificationCard = Color(0xFF1E293B);
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF334155);

  /// Doctor Green Palette
  static const Color doctorGreen = Color(0xFF2D7A4F);
  static const Color doctorGreenLight = Color(0xFF3A9D63);
  static const Color doctorGreenDark = Color(0xFF1B5E3A);

  /// Gradient for header (PDF requirement: gradient background at top)
  static const List<Color> headerGradient = [
    Color(0xFFC50018),
    Color(0xFFE03348),
  ];

  static const List<Color> headerGradientDark = [
    Color(0xFF8E0006),
    Color(0xFFC50018),
  ];

  /// Doctor header gradient (green)
  static const List<Color> doctorHeaderGradient = [
    Color(0xFF1B5E3A),
    Color(0xFF2D7A4F),
  ];

  static const List<Color> doctorHeaderGradientDark = [
    Color(0xFF14452C),
    Color(0xFF1B5E3A),
  ];
}

/// Dynamic color picker
class ThemeColors {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color primary(BuildContext context) =>
      isDark(context) ? AppColors.darkPrimary : AppColors.lightPrimary;

  static Color secondary(BuildContext context) =>
      isDark(context) ? AppColors.darkSecondary : AppColors.lightSecondary;

  static Color tertiary(BuildContext context) =>
      isDark(context) ? AppColors.darkTertiary : AppColors.lightTertiary;

  static Color background(BuildContext context) =>
      isDark(context) ? AppColors.darkBackground : AppColors.lightBackground;

  static Color surface(BuildContext context) =>
      isDark(context) ? AppColors.darkSurface : AppColors.lightSurface;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      isDark(context)
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary;

  static Color notificationCard(BuildContext context) =>
      isDark(context)
          ? AppColors.darkNotificationCard
          : AppColors.lightNotificationCard;

  static Color divider(BuildContext context) =>
      isDark(context) ? AppColors.darkDivider : AppColors.lightDivider;

  static Color border(BuildContext context) =>
      isDark(context) ? AppColors.darkBorder : AppColors.lightBorder;

  static Color error(BuildContext context) =>
      isDark(context) ? AppColors.darkError : AppColors.error;

  static Color success(BuildContext context) => AppColors.success;
  static Color warning(BuildContext context) => AppColors.warning;
  static Color info(BuildContext context) => AppColors.info;
}
