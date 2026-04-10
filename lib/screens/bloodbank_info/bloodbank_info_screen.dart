import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rudhirakshapp/controllers/global_profile_controller.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';

class BloodBankInfoScreen extends StatelessWidget {
  const BloodBankInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final globalProfile = Get.find<GlobalProfileController>();
    final data = globalProfile.bloodBankData['data'] ?? {};

    final name = data['name'] ?? 'Blood Bank';
    final logoUrl = data['logo_url'] ?? data['logoUrl'] ?? '';
    final email = data['contact_email'] ?? data['contactEmail'] ?? '';
    final phone = data['contact_phone'] ?? data['contactPhone'] ?? '';
    final address = data['metadata']?['address'] ?? data['address'] ?? '';
    final description = data['description'] ?? 'No description available.';

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Gradient header with logo
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.brandCrimson,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.headerGradient,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      if (logoUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: logoUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorWidget: (_, _a, _b) => _logoPlaceholder(),
                          ),
                        )
                      else
                        _logoPlaceholder(),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About
                  _sectionTitle('About', colors),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.borderColor),
                    ),
                    child: Text(
                      description,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Contact Info
                  _sectionTitle('Contact Information', colors),
                  const SizedBox(height: 8),
                  if (phone.isNotEmpty)
                    _contactTile(
                      icon: SolarLinearIcons.phone,
                      label: 'Phone',
                      value: phone,
                      colors: colors,
                      onTap: () => launchUrl(Uri.parse('tel:$phone')),
                    ),
                  if (email.isNotEmpty)
                    _contactTile(
                      icon: SolarLinearIcons.letter,
                      label: 'Email',
                      value: email,
                      colors: colors,
                      onTap: () => launchUrl(Uri.parse('mailto:$email')),
                    ),
                  if (address.isNotEmpty)
                    _contactTile(
                      icon: SolarLinearIcons.mapPoint,
                      label: 'Address',
                      value: address,
                      colors: colors,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(SolarLinearIcons.buildings2, color: Colors.white, size: 40),
    );
  }

  Widget _sectionTitle(String title, AppThemeColors colors) {
    return Text(
      title,
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String label,
    required String value,
    required AppThemeColors colors,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brandRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.brandRed),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(SolarLinearIcons.altArrowRight, size: 18, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
