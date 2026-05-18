import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/controllers/login_controller.dart';
import '../../../core/widgets/custom_modern_text_field.dart';
import '../../../core/theme/app_theme_colors.dart';

class LoginFormContainer extends StatelessWidget {
  final LoginController loginController;
  const LoginFormContainer({super.key, required this.loginController});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final colors = AppThemeColors.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // User ID Field
        Obx(
          () => ModernTextField(
            controller: loginController.userIdController,
            labelText: "User ID (Email/Phone)",
            prefixIcon: SolarLinearIcons.userCircle,
            errorText: loginController.userIdError.value,
            onChanged: loginController.validateUserIdDebounced,
            screenWidth: screenWidth,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),

        // Password Field
        Obx(
          () => ModernTextField(
            controller: loginController.passwordController,
            labelText: "Password",
            prefixIcon: SolarLinearIcons.lockKeyhole,
            obscureText: loginController.isPasswordHidden.value,
            errorText: loginController.passwordError.value,
            onChanged: loginController.validatePasswordDebounced,
            suffixIcon: IconButton(
              icon: Icon(
                loginController.isPasswordHidden.value
                    ? SolarLinearIcons.eyeClosed
                    : SolarLinearIcons.eye,
                color: colors.textSecondary,
                size: 22,
              ),
              onPressed: loginController.togglePasswordVisibility,
            ),
            screenWidth: screenWidth,
          ),
        ),
      ],
    );
  }
}
