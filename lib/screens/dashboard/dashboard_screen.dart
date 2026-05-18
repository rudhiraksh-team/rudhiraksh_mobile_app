// ignore_for_file: unused_local_variable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/controllers/global_profile_controller.dart';
import 'package:rudhirakshapp/controllers/splash_controller.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/enums/transfusion_status.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/core/utils/string_utils.dart';
import 'package:rudhirakshapp/controllers/patient_lab_requests_controller.dart';
import 'package:rudhirakshapp/data/helper%20function/navigation_helper.dart';
import 'package:rudhirakshapp/data/services/push_notification_service.dart';
import 'package:rudhirakshapp/screens/articles/articles_screen.dart';
import 'package:rudhirakshapp/screens/patient_health/patient_health_screen.dart';
import 'package:rudhirakshapp/screens/dashboard/widgets/calender.dart';
import 'package:rudhirakshapp/screens/medical%20history/medical_records_screen.dart';
import 'package:rudhirakshapp/screens/user%20profile/profile_review_screen.dart';
import '../../controllers/dashboard_controller.dart';
import 'widgets/upcoming_transfusion_card.dart';
import 'package:rudhirakshapp/data/models/transfusion_list_model.dart'
    as tmodel;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    final controller = Get.find<DashboardController>();
    final colors = AppThemeColors.of(context);
    final isDark = colors.isDark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    Widget homeContent() {
      return RefreshIndicator(
        color: colors.primaryColor,
        onRefresh: () async {
          await Get.put(SplashController()).refreshAllData();
        },
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
                        ? AppColors.headerGradientDark
                        : AppColors.headerGradient,
                  ),
                ),
                child: Row(
                  children: [
                    // Blood Bank Avatar
                    Obx(
                      () => GestureDetector(
                        onTap: NavigationHelper.goToBloodBankInfo,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white.withValues(alpha: 0.2),
                            image: controller.bloodBankPhoto.value.isNotEmpty
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      controller.bloodBankPhoto.value,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: controller.bloodBankPhoto.value.isEmpty
                              ? const Icon(
                                  SolarLinearIcons.buildings,
                                  size: 20,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              controller.bloodBankName.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Obx(
                            () => Text(
                              'Hi, ${StringUtils.getFirstName(controller.userName.value)}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Notification bell
                    GestureDetector(
                      onTap: NavigationHelper.goToNotificationScreen,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          SolarLinearIcons.bellBing,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Profile avatar
                    Obx(() {
                      // The getter reads profileData['data'], which triggers
                      // Obx subscription so this rebuilds on photo updates.
                      final photoUrl =
                          Get.find<GlobalProfileController>().profilePhotoUrl;
                      return GestureDetector(
                        onTap: () => controller.bottomNavIndex.value = 4,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            image: photoUrl != null
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(photoUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: photoUrl == null
                              ? const Icon(
                                  SolarLinearIcons.userRounded,
                                  color: Colors.white,
                                  size: 22,
                                )
                              : null,
                        ),
                      );
                    }),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: 24,
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
                        SizedBox(height: screenHeight * 0.018),

                        // Stats row
                        _DashboardStatsRow(
                            controller: controller, colors: colors),
                        SizedBox(height: screenHeight * 0.025),

                        // Transfusions section
                        Text(
                          'Transfusions',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        CalendarSection(controller: controller),
                        SizedBox(height: screenHeight * 0.02),

                        Obx(() {
                          final tmodel.Transfusion? selected =
                              controller.selectedTransfusionRx.value;
                          if (selected != null) {
                            TransfusionStatus status;
                            if (controller.doneTransfusions
                                .contains(selected)) {
                              status = TransfusionStatus.done;
                            } else if (controller.missedTransfusions.any(
                              (m) =>
                                  m.expectedDate != null &&
                                  selected.visitDate != null &&
                                  m.expectedDate!
                                      .isAtSameMomentAs(selected.visitDate!),
                            )) {
                              status = TransfusionStatus.missed;
                            } else if (controller.upcomingTransfusion.value ==
                                selected) {
                              status = TransfusionStatus.upcoming;
                            } else {
                              status = TransfusionStatus.done;
                            }
                          }
                          return const SizedBox.shrink();
                        }),

                        Obx(() {
                          final tmodel.Transfusion? selected =
                              controller.selectedTransfusionRx.value;
                          if (selected != null) {
                            TransfusionStatus status;
                            if (controller.doneTransfusions
                                .contains(selected)) {
                              status = TransfusionStatus.done;
                            } else if (controller.missedTransfusions.any(
                              (m) =>
                                  m.expectedDate != null &&
                                  selected.visitDate != null &&
                                  m.expectedDate!
                                      .isAtSameMomentAs(selected.visitDate!),
                            )) {
                              status = TransfusionStatus.missed;
                            } else if (controller.upcomingTransfusion.value ==
                                selected) {
                              status = TransfusionStatus.upcoming;
                            } else {
                              status = TransfusionStatus.done;
                            }

                            return UpcomingTransfusionCardWidget(
                              transfusion: selected,
                              status: status,
                            );
                          } else {
                            final upcoming =
                                controller.upcomingTransfusion.value;
                            if (upcoming != null) {
                              return UpcomingTransfusionCardWidget(
                                transfusion: upcoming,
                                status: TransfusionStatus.upcoming,
                              );
                            } else {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: colors.surfaceColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: colors.borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.calendarAccent
                                            .withValues(alpha: 0.08),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        SolarLinearIcons.calendarMinimalistic,
                                        color: AppColors.calendarAccent,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        "No transfusion info for selected date.",
                                        style: TextStyle(
                                          color: colors.textSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        }),

                        SizedBox(height: screenHeight * 0.025),
                        const _LabRequestsCard(),

                        SizedBox(height: screenHeight * 0.08),
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

    Widget transfusionHistoryPage() {
      return const MedicalRecordsScreen();
    }

    Widget healthPage() {
      return const PatientHealthScreen();
    }

    Widget articlesPage() {
      return const ArticlesScreen();
    }

    Widget profilePage() {
      return const ProfileReviewScreen(isFromDashboard: true);
    }

    return Obx(() {
      final idx = controller.bottomNavIndex.value;
      return Scaffold(
        backgroundColor: colors.backgroundColor,
        body: IndexedStack(
          index: idx,
          children: [
            homeContent(),
            transfusionHistoryPage(),
            healthPage(),
            articlesPage(),
            profilePage(),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                      SolarLinearIcons.homeAngle,
                      size: 24,
                      color: colors.textSecondary,
                    ),
                    selectedIcon: Icon(
                      SolarBoldIcons.homeAngle,
                      size: 24,
                      color: colors.primaryColor,
                    ),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      SolarLinearIcons.history,
                      size: 24,
                      color: colors.textSecondary,
                    ),
                    selectedIcon: Icon(
                      SolarBoldIcons.history,
                      size: 24,
                      color: colors.primaryColor,
                    ),
                    label: 'History',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      SolarLinearIcons.heartPulse,
                      size: 24,
                      color: colors.textSecondary,
                    ),
                    selectedIcon: Icon(
                      SolarBoldIcons.heartPulse,
                      size: 24,
                      color: colors.primaryColor,
                    ),
                    label: 'Health',
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
                    label: 'Blogs',
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

/// Dashboard stats - Recent Ferritin Level and Recent HB
class _DashboardStatsRow extends StatelessWidget {
  final DashboardController controller;
  final AppThemeColors colors;

  const _DashboardStatsRow({required this.controller, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      String ferritinValue = 'N/A';
      String hbValue = 'N/A';

      if (controller.doneTransfusions.isNotEmpty) {
        final latest = controller.doneTransfusions.first;
        if (latest.preHb != null) {
          hbValue = latest.preHb!.toStringAsFixed(1);
        }
      }

      return Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Recent Ferritin Level',
              value: ferritinValue,
              unit: ferritinValue != 'N/A' ? 'ng/mL' : '',
              color: AppColors.brandCrimson,
              icon: SolarLinearIcons.testTube,
              colors: colors,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'Recent HB',
              value: hbValue,
              unit: hbValue != 'N/A' ? 'g/dL' : '',
              color: AppColors.brandRed,
              icon: SolarLinearIcons.heartPulse,
              colors: colors,
            ),
          ),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;
  final AppThemeColors colors;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Lab Requests entry card on patient home — shows pending count badge,
/// taps through to the full Lab Requests screen.
class _LabRequestsCard extends StatelessWidget {
  const _LabRequestsCard();

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final controller = Get.put(PatientLabRequestsController(), permanent: true);

    return GestureDetector(
      onTap: NavigationHelper.goToPatientLabRequests,
      child: Obx(() {
        final pending = controller.pendingCount;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.borderColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brandCrimson.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  SolarLinearIcons.testTube,
                  color: AppColors.brandCrimson,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lab Requests',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pending > 0
                          ? '$pending pending'
                          : 'No pending requests',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (pending > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brandCrimson,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$pending',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              Icon(SolarLinearIcons.altArrowRight,
                  color: colors.textSecondary, size: 20),
            ],
          ),
        );
      }),
    );
  }
}
