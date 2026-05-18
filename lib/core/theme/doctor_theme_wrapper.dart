import 'package:flutter/material.dart';
import 'package:rudhirakshapp/core/theme/app_theme.dart';

/// Wraps a doctor screen with the green doctor theme.
/// All `AppThemeColors.of(context).primaryColor` calls inside
/// will resolve to green instead of the default red.
class DoctorThemeWrapper extends StatelessWidget {
  final Widget child;
  const DoctorThemeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: isDark ? AppTheme.doctorDarkTheme : AppTheme.doctorLightTheme,
      child: child,
    );
  }
}
