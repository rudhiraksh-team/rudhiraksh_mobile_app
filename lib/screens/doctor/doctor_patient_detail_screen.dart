import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/controllers/doctor_patient_detail_controller.dart';
import 'package:rudhirakshapp/data/models/doctor_models.dart';
import 'package:rudhirakshapp/screens/doctor/widgets/transfusion_list_tab.dart';
import 'package:rudhirakshapp/screens/doctor/widgets/growth_chart_tab.dart';
import 'package:rudhirakshapp/screens/doctor/widgets/documents_tab.dart';
import 'package:rudhirakshapp/screens/doctor/widgets/lab_requests_tab.dart';
import 'package:rudhirakshapp/screens/doctor/widgets/ferritin_tab.dart';
import 'package:rudhirakshapp/screens/doctor/widgets/chelation_tab.dart';
import 'package:rudhirakshapp/screens/doctor/widgets/images_tab.dart';

class DoctorPatientDetailScreen extends StatelessWidget {
  const DoctorPatientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final int patientId = args['patientId'];
    final AssignedPatient patient = args['patient'];

    final controller = Get.put(
      DoctorPatientDetailController(patientId: patientId),
      tag: 'patient_$patientId',
    );

    final colors = AppThemeColors.of(context);

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        backgroundColor: colors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.doctorGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (patient.bloodGroup != null && patient.bloodGroup!.isNotEmpty)
                Text(
                  '${patient.bloodGroup} • ${patient.age}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              if (patient.thalassemiaPatientId != null &&
                  patient.thalassemiaPatientId!.isNotEmpty)
                Text(
                  'Thalassemia ID: ${patient.thalassemiaPatientId}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
            ],
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
            tabs: const [
              Tab(text: 'Transfusions'),
              Tab(text: 'Growth'),
              Tab(text: 'Ferritin'),
              Tab(text: 'Chelation'),
              Tab(text: 'Documents'),
              Tab(text: 'Lab Requests'),
              Tab(text: 'Images'),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(color: colors.primaryColor),
              );
            }
            return TabBarView(
              children: [
                TransfusionListTab(controller: controller),
                GrowthChartTab(controller: controller),
                FerritinTab(controller: controller),
                ChelationTab(controller: controller),
                DocumentsTab(controller: controller),
                LabRequestsTab(controller: controller),
                ImagesTab(controller: controller),
              ],
            );
          }),
        ),
      ),
    );
  }
}
