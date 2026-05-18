import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudhirakshapp/controllers/global_profile_controller.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final globalProfile = Get.find<GlobalProfileController>();

    final bloodBankData = globalProfile.bloodBankData;
    final termsAndConditions = bloodBankData['data']?['terms_and_conditions'] ??
        bloodBankData['data']?['termsAndConditions'] ??
        _defaultTerms;
    final bankName = bloodBankData['data']?['name'] ?? 'Blood Bank';

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$bankName',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Terms & Conditions',
              style: TextStyle(
                color: colors.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.borderColor),
              ),
              child: Text(
                termsAndConditions,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Privacy Policy',
              style: TextStyle(
                color: colors.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.borderColor),
              ),
              child: Text(
                _defaultPrivacyPolicy,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const String _defaultTerms = '''
Terms and Conditions

1. By using the Rudhiraksh application, you agree to these terms and conditions.

2. Patient Data: All patient data is stored securely and is only accessible to authorized medical staff and the patient themselves.

3. Medical Records: Transfusion records and medical data are maintained for clinical purposes and regulatory compliance.

4. Privacy: Your personal health information is protected and will not be shared with third parties without your consent, except as required by law.

5. Account Security: You are responsible for maintaining the confidentiality of your login credentials. Report any unauthorized access immediately.

6. Consent: By using this application, you consent to the collection and use of your health data for treatment purposes.

7. Modifications: These terms may be updated periodically. Continued use of the app constitutes acceptance of modified terms.

8. Liability: The application is a health management tool and does not replace professional medical advice. Always consult your healthcare provider for medical decisions.
''';

  static const String _defaultPrivacyPolicy = '''
Privacy Policy

Your privacy is important to us. This policy explains how we collect, use, and protect your information.

Data Collection:
- Personal identification information (name, email, phone)
- Medical records and health data
- Device information for push notifications

Data Usage:
- To provide and maintain our service
- To manage your appointments and transfusion schedule
- To send important health reminders and notifications

Data Protection:
- All data is encrypted in transit and at rest
- Access is restricted to authorized medical personnel
- Regular security audits are performed

Your Rights:
- Access your personal data at any time
- Request correction of inaccurate data
- Request deletion of your data (subject to medical record retention requirements)

Contact us for any privacy-related concerns.
''';
}
