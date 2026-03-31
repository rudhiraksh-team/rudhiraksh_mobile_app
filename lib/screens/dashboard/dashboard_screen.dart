// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/controllers/splash_controller.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/enums/transfusion_status.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/data/services/push_notification_service.dart';
import 'package:rudhirakshapp/screens/articles/articles_screen.dart';
import 'package:rudhirakshapp/screens/dashboard/widgets/calender.dart';
import 'package:rudhirakshapp/screens/dashboard/widgets/dashboard_app_bar.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Widget homeContent() {
      return RefreshIndicator(
        color: colors.primaryColor,
        onRefresh: () async {
          await Get.put(SplashController()).refreshAllData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.015,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PDF #12: Dashboard stats - Recent Ferritin & HB
              _DashboardStatsRow(controller: controller, colors: colors),
              SizedBox(height: screenHeight * 0.02),

              // Transfusions section title
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
                  if (controller.doneTransfusions.contains(selected)) {
                    status = TransfusionStatus.done;
                  } else if (controller.missedTransfusions.any(
                    (m) =>
                        m.expectedDate != null &&
                        selected.visitDate != null &&
                        m.expectedDate!.isAtSameMomentAs(selected.visitDate!),
                  )) {
                    status = TransfusionStatus.missed;
                  } else if (controller.upcomingTransfusion.value == selected) {
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
                  if (controller.doneTransfusions.contains(selected)) {
                    status = TransfusionStatus.done;
                  } else if (controller.missedTransfusions.any(
                    (m) =>
                        m.expectedDate != null &&
                        selected.visitDate != null &&
                        m.expectedDate!.isAtSameMomentAs(selected.visitDate!),
                  )) {
                    status = TransfusionStatus.missed;
                  } else if (controller.upcomingTransfusion.value == selected) {
                    status = TransfusionStatus.upcoming;
                  } else {
                    status = TransfusionStatus.done;
                  }

                  return UpcomingTransfusionCardWidget(
                    transfusion: selected,
                    status: status,
                  );
                } else {
                  final upcoming = controller.upcomingTransfusion.value;
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
                        border: Border.all(color: colors.borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.calendarAccent.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
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

              SizedBox(height: screenHeight * 0.08),
            ],
          ),
        ),
      );
    }

    Widget transfusionHistoryPage() {
      return const MedicalRecordsScreen();
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
        // PDF #9: Gradient header - only show on home tab
        appBar: idx == 0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: SafeArea(
                  child: DashboardAppBar(controller: controller),
                ),
              )
            : null,
        body: IndexedStack(
          index: idx,
          children: [
            homeContent(),
            transfusionHistoryPage(),
            articlesPage(),
            profilePage(),
          ],
        ),
        // PDF #12: Bottom nav - Home, History, Blogs Tab, Profile
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
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                elevation: 0,
                height: 64,
                backgroundColor: Colors.transparent,
                indicatorColor: colors.primaryColor.withValues(alpha: 0.1),
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

/// PDF #12: Dashboard stats - Recent Ferritin Level and Recent HB
class _DashboardStatsRow extends StatelessWidget {
  final DashboardController controller;
  final AppThemeColors colors;

  const _DashboardStatsRow({required this.controller, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Get latest transfusion data for ferritin and HB
      String ferritinValue = 'N/A';
      String hbValue = 'N/A';

      if (controller.doneTransfusions.isNotEmpty) {
        // Get the most recent completed transfusion
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
            children: [
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
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
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
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
