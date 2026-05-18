import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/controllers/global_profile_controller.dart';
import 'package:rudhirakshapp/core/widgets/custom_elevated_button.dart';
import 'package:rudhirakshapp/data/models/blood_bank_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CallButton extends StatelessWidget {
  const CallButton({super.key});

  @override
  Widget build(BuildContext context) {
    final globalProfile = Get.find<GlobalProfileController>();

    String phoneNumber = '';
    try {
      if (globalProfile.bloodBankData.isNotEmpty) {
        final bank = BloodBank.fromJson(
          Map<String, dynamic>.from(globalProfile.bloodBankData),
        );
        phoneNumber = bank.contactPhone ?? '';
      }
    } catch (e) {
      phoneNumber = '';
    }

    return CustomElevatedButton(
      label: "Contact Blood Bank",
      icon: SolarLinearIcons.phoneCalling,
      onPressed: () async {
        if (phoneNumber.isEmpty) {
          Get.snackbar('Error', 'No contact number found');
          return;
        }

        String sanitizedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
        if (!sanitizedNumber.startsWith('+')) {
          sanitizedNumber = '+91$sanitizedNumber';
        }

        final telUri = Uri(scheme: 'tel', path: sanitizedNumber);

        try {
          if (!await launchUrl(telUri)) {
            await launchUrlString('tel:$sanitizedNumber');
          }
        } catch (e) {
          Get.snackbar('Error', 'Unable to open dialer');
        }
      },
    );
  }
}
