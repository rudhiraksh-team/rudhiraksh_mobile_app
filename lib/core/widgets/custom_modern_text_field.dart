import 'package:flutter/material.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';

class ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final double screenWidth;
  final String? errorText;
  final bool obscureText;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    required this.screenWidth,
    this.errorText,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      readOnly: readOnly,
      validator: validator,
      onTap: onTap,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: screenWidth * 0.04,
        color: colors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: colors.textSecondary,
          fontSize: screenWidth * 0.038,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            prefixIcon,
            color: colors.primaryColor.withValues(alpha: 0.7),
            size: screenWidth * 0.05,
          ),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colors.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : colors.primaryColor.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colors.primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.errorColor, width: 2),
        ),
        errorText: errorText,
        errorStyle: TextStyle(
          fontSize: screenWidth * 0.033,
          color: colors.errorColor,
          fontWeight: FontWeight.w400,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}
