import 'package:flutter/material.dart';

/// Centralized color getter based on current theme
class AppThemeColors {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color errorColor;
  final Color cardColor;
  final Color surfaceVariant;
  final Color dividerColor;
  final Color borderColor;
  final Brightness brightness;

  AppThemeColors({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.errorColor,
    required this.cardColor,
    required this.surfaceVariant,
    required this.dividerColor,
    required this.borderColor,
    required this.brightness,
  });

  bool get isDark => brightness == Brightness.dark;

  factory AppThemeColors.of(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppThemeColors(
      primaryColor: colorScheme.primary,
      secondaryColor: colorScheme.secondary,
      backgroundColor: isDark
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surfaceContainerHighest,
      surfaceColor: colorScheme.surface,
      textPrimary: colorScheme.onSurface,
      textSecondary: colorScheme.onSurface.withValues(alpha: 0.55),
      errorColor: colorScheme.error,
      cardColor: colorScheme.surface,
      surfaceVariant: colorScheme.onSurfaceVariant,
      dividerColor: colorScheme.outline.withValues(alpha: 0.1),
      borderColor: colorScheme.outline.withValues(alpha: 0.15),
      brightness: Theme.of(context).brightness,
    );
  }
}
