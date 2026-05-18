import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Font family names used in the app.
// PDF requirement: Use Manrope font family
class AppFonts {
  static const String primaryFont = "Manrope";
  static const String secondaryFont = "Manrope";

  /// Get the Manrope TextTheme via Google Fonts
  static TextTheme manropeTextTheme([TextTheme? base]) {
    return GoogleFonts.manropeTextTheme(base);
  }

  /// Get a Manrope TextStyle
  static TextStyle manrope({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}
