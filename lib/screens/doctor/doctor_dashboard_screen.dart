import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/controllers/doctor_dashboard_controller.dart';
import 'package:rudhirakshapp/controllers/doctor_profile_controller.dart';
import 'package:rudhirakshapp/controllers/notification_controller.dart';
import 'package:rudhirakshapp/data/helper%20function/navigation_helper.dart';
import 'package:rudhirakshapp/data/services/push_notification_service.dart';
import 'package:rudhirakshapp/screens/doctor/widgets/patient_card.dart';
import 'package:rudhirakshapp/screens/doctor/doctor_profile_screen.dart';
import 'package:rudhirakshapp/screens/articles/articles_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        PushNotificationService.registerForNotificationsIfNeeded();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorDashboardController());
    final profileController = Get.put(DoctorProfileController());
    final colors = AppThemeColors.of(context);
    final isDark = colors.isDark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    Widget patientsTab() {
      return RefreshIndicator(
        color: colors.primaryColor,
        onRefresh: () => controller.refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ── Colored Header Area ──
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: statusBarHeight + 16,
                  left: 20,
                  right: 20,
                  bottom: 40,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? AppColors.doctorHeaderGradientDark
                        : AppColors.doctorHeaderGradient,
                  ),
                ),
                child: Row(
                  children: [
                    // Blood bank logo
                    Obx(() => Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white.withValues(alpha: 0.2),
                            image: profileController
                                    .bloodBankLogo.isNotEmpty
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      profileController.bloodBankLogo,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: profileController
                                  .bloodBankLogo.isEmpty
                              ? const Icon(
                                  SolarLinearIcons.hospital,
                                  size: 22,
                                  color: Colors.white,
                                )
                              : null,
                        )),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        final name = profileController.doctorName;
                        final bank = profileController.bloodBankName;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isNotEmpty
                                  ? 'Hi, $name'
                                  : 'My Patients',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (bank.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                bank,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        );
                      }),
                    ),
                    // Notification bell
                    GestureDetector(
                      onTap: NavigationHelper.goToNotificationScreen,
                      child: Obx(() {
                        final notifCtrl = Get.put(NotificationController());
                        final unreadCount = notifCtrl.notifications
                            .where((n) => !n.isRead)
                            .length;
                        return Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                SolarLinearIcons.bellBing,
                                color: Colors.white,
                                size: 22,
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      unreadCount > 9 ? '9+' : '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    // Profile avatar
                    GestureDetector(
                      onTap: () => controller.bottomNavIndex.value = 2,
                      child: Obx(() => Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: profileController.initials.isNotEmpty
                                  ? Text(
                                      profileController.initials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : const Icon(
                                      SolarLinearIcons.userRounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                            ),
                          )),
                    ),
                  ],
                ),
              ),

              // ── White Card Content ──
              Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: screenHeight * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color: colors.backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * 0.04,
                      right: screenWidth * 0.04,
                      top: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dashboard title
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Quick Stats Row ──
                        Obx(() => Row(
                              children: [
                                _StatChip(
                                  icon: SolarLinearIcons.usersGroupRounded,
                                  label: 'Total',
                                  value:
                                      '${controller.assignedPatients.length}',
                                  color: AppColors.info,
                                  colors: colors,
                                ),
                                const SizedBox(width: 8),
                                _StatChip(
                                  icon: SolarLinearIcons.clockCircle,
                                  label: 'Upcoming',
                                  value:
                                      '${controller.upcomingTransfusionCount}',
                                  color: AppColors.upcoming,
                                  colors: colors,
                                ),
                                const SizedBox(width: 8),
                                _StatChip(
                                  icon: SolarLinearIcons.shieldWarning,
                                  label: 'Low HB',
                                  value: '${controller.lowHbCount}',
                                  color: AppColors.error,
                                  colors: colors,
                                ),
                                if (controller.missedTransfusionCount >
                                    0) ...[
                                  const SizedBox(width: 8),
                                  _StatChip(
                                    icon: SolarLinearIcons.closeCircle,
                                    label: 'Missed',
                                    value:
                                        '${controller.missedTransfusionCount}',
                                    color: AppColors.warning,
                                    colors: colors,
                                  ),
                                ],
                              ],
                            )),
                        const SizedBox(height: 16),

                        // ── Search Bar ──
                        TextField(
                          onChanged: (val) =>
                              controller.searchQuery.value = val,
                          style: TextStyle(
                              color: colors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search patients...',
                            hintStyle: TextStyle(
                                color: colors.textSecondary, fontSize: 13),
                            prefixIcon: Icon(
                              SolarLinearIcons.magnifer,
                              size: 20,
                              color: colors.textSecondary,
                            ),
                            filled: true,
                            fillColor: colors.surfaceColor,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  BorderSide(color: colors.borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  BorderSide(color: colors.borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: colors.primaryColor, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Patient Count + List ──
                        Obx(() => Text(
                              '${controller.filteredPatients.length} patient${controller.filteredPatients.length == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            )),
                        const SizedBox(height: 8),

                        Obx(() {
                          if (controller.isLoading.value &&
                              controller.assignedPatients.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.only(top: screenHeight * 0.1),
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: colors.primaryColor),
                              ),
                            );
                          }

                          if (controller.filteredPatients.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.only(top: screenHeight * 0.1),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      SolarLinearIcons.usersGroupRounded,
                                      size: 48,
                                      color: colors.textSecondary,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      controller
                                              .searchQuery.value.isNotEmpty
                                          ? 'No matching patients'
                                          : 'No patients assigned yet',
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: controller.filteredPatients
                                .map((patient) => PatientCard(
                                      patient: patient,
                                      onTap: () => NavigationHelper
                                          .goToDoctorPatientDetail(
                                        patient.patientId,
                                        patient,
                                      ),
                                    ))
                                .toList(),
                          );
                        }),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget articlesTab() {
      return const ArticlesScreen();
    }

    Widget profileTab() {
      return const DoctorProfileScreen();
    }

    return Obx(() {
      final idx = controller.bottomNavIndex.value;
      return Scaffold(
        backgroundColor: colors.backgroundColor,
        body: IndexedStack(
          index: idx,
          children: [
            patientsTab(),
            articlesTab(),
            profileTab(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: colors.surfaceColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: NavigationBar(
                selectedIndex: idx,
                onDestinationSelected: (index) {
                  controller.bottomNavIndex.value = index;
                },
                labelBehavior:
                    NavigationDestinationLabelBehavior.alwaysShow,
                elevation: 0,
                height: 64,
                backgroundColor: Colors.transparent,
                indicatorColor:
                    colors.primaryColor.withValues(alpha: 0.1),
                destinations: [
                  NavigationDestination(
                    icon: Icon(
                      SolarLinearIcons.usersGroupRounded,
                      size: 24,
                      color: colors.textSecondary,
                    ),
                    selectedIcon: Icon(
                      SolarBoldIcons.usersGroupRounded,
                      size: 24,
                      color: colors.primaryColor,
                    ),
                    label: 'Patients',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      SolarLinearIcons.notebook,
                      size: 24,
                      color: colors.textSecondary,
                    ),
                    selectedIcon: Icon(
                      SolarBoldIcons.notebook,
                      size: 24,
                      color: colors.primaryColor,
                    ),
                    label: 'Articles',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      SolarLinearIcons.userRounded,
                      size: 24,
                      color: colors.textSecondary,
                    ),
                    selectedIcon: Icon(
                      SolarBoldIcons.userRounded,
                      size: 24,
                      color: colors.primaryColor,
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ── Stat Chip ──────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final AppThemeColors colors;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
