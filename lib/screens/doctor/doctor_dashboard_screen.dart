import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/controllers/doctor_dashboard_controller.dart';
import 'package:rudhirakshapp/data/helper%20function/navigation_helper.dart';
import 'package:rudhirakshapp/screens/doctor/widgets/patient_card.dart';
import 'package:rudhirakshapp/screens/doctor/doctor_profile_screen.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorDashboardController>();
    final colors = AppThemeColors.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Widget patientsTab() {
      return RefreshIndicator(
        color: colors.primaryColor,
        onRefresh: () => controller.refreshData(),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.04,
                screenHeight * 0.015,
                screenWidth * 0.04,
                8,
              ),
              child: TextField(
                onChanged: (val) => controller.searchQuery.value = val,
                style: TextStyle(color: colors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search patients...',
                  hintStyle: TextStyle(color: colors.textSecondary, fontSize: 13),
                  prefixIcon: Icon(
                    SolarLinearIcons.magnifer,
                    size: 20,
                    color: colors.textSecondary,
                  ),
                  filled: true,
                  fillColor: colors.surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.primaryColor, width: 1.5),
                  ),
                ),
              ),
            ),

            // Patient count
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Obx(() => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${controller.filteredPatients.length} patient${controller.filteredPatients.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )),
            ),
            const SizedBox(height: 8),

            // Patient list
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.assignedPatients.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(color: colors.primaryColor),
                  );
                }

                if (controller.filteredPatients.isEmpty) {
                  return Center(
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
                          controller.searchQuery.value.isNotEmpty
                              ? 'No matching patients'
                              : 'No patients assigned yet',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: controller.filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patient = controller.filteredPatients[index];
                    return PatientCard(
                      patient: patient,
                      onTap: () => NavigationHelper.goToDoctorPatientDetail(
                        patient.patientId,
                        patient,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      );
    }

    Widget profileTab() {
      return const DoctorProfileScreen();
    }

    return Obx(() {
      final idx = controller.bottomNavIndex.value;
      return Scaffold(
        backgroundColor: colors.backgroundColor,
        appBar: idx == 0
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 70,
                automaticallyImplyLeading: false,
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.brandCrimson, AppColors.brandRed],
                    ),
                  ),
                ),
                title: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Patients',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Assigned patient list',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              )
            : null,
        body: IndexedStack(
          index: idx,
          children: [
            patientsTab(),
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
