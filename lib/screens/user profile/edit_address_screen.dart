import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';

import '../../controllers/edit_address_controller.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/widgets/custom_modern_text_field.dart';

class EditAddressScreen extends StatelessWidget {
  const EditAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditAddressController());
    final colors = AppThemeColors.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: colors.backgroundColor,
        elevation: 0,
        title: Text(
          'Edit Address',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 8),
              Obx(() => ModernTextField(
                    labelText: 'Street',
                    controller: controller.streetController,
                    prefixIcon: SolarLinearIcons.streetsMapPoint,
                    screenWidth: screenWidth,
                    keyboardType: TextInputType.streetAddress,
                    errorText: controller.streetError.value,
                  )),
              const SizedBox(height: 12),
              Obx(() => ModernTextField(
                    labelText: 'Area',
                    controller: controller.areaController,
                    prefixIcon: SolarLinearIcons.map,
                    screenWidth: screenWidth,
                    keyboardType: TextInputType.streetAddress,
                    errorText: controller.areaError.value,
                  )),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => ModernTextField(
                          labelText: 'City',
                          controller: controller.cityController,
                          prefixIcon: SolarLinearIcons.buildings2,
                          screenWidth: screenWidth,
                          keyboardType: TextInputType.text,
                          errorText: controller.cityError.value,
                        )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ModernTextField(
                          labelText: 'State',
                          controller: controller.stateController,
                          prefixIcon: SolarLinearIcons.mapPoint,
                          screenWidth: screenWidth,
                          keyboardType: TextInputType.text,
                          errorText: controller.stateError.value,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() => ModernTextField(
                    labelText: 'Pincode',
                    controller: controller.pincodeController,
                    prefixIcon: SolarLinearIcons.mapPointWave,
                    screenWidth: screenWidth,
                    keyboardType: TextInputType.number,
                    errorText: controller.pincodeError.value,
                  )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 12,
          ),
          child: Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              )),
        ),
      ),
    );
  }
}
