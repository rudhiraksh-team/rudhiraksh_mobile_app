import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// App-wide text styles using Manrope (PDF requirement)
class AppTypography {
  /// ----------------------------
  /// HEADINGS
  /// ----------------------------
  static TextStyle heading1(BuildContext context) => GoogleFonts.manrope(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: ThemeColors.textPrimary(context),
  );

  static TextStyle heading2(BuildContext context) => GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: ThemeColors.textPrimary(context),
  );

  static TextStyle heading3(BuildContext context) => GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: ThemeColors.textPrimary(context),
  );

  /// ----------------------------
  /// BODY
  /// ----------------------------
  static TextStyle body(BuildContext context) => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: ThemeColors.textSecondary(context),
  );

  static TextStyle bodyBold(BuildContext context) => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ThemeColors.textPrimary(context),
  );

  /// ----------------------------
  /// CAPTION / SMALL TEXT
  /// ----------------------------
  static TextStyle caption(BuildContext context) => GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: ThemeColors.textSecondary(context),
  );

  static TextStyle captionBold(BuildContext context) => GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: ThemeColors.textPrimary(context),
  );

  /// ----------------------------
  /// BUTTON TEXT
  /// ----------------------------
  static TextStyle button(BuildContext context) => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// ----------------------------
  /// INPUT LABEL
  /// ----------------------------
  static TextStyle inputLabel(BuildContext context) => GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ThemeColors.textSecondary(context),
  );
}
