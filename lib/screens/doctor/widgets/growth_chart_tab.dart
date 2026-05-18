import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/controllers/doctor_patient_detail_controller.dart';
import 'package:rudhirakshapp/data/models/doctor_models.dart';

class GrowthChartTab extends StatelessWidget {
  final DoctorPatientDetailController controller;

  const GrowthChartTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return Obx(() {
      if (controller.growthEntries.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(SolarLinearIcons.chartSquare, size: 48, color: colors.textSecondary),
              const SizedBox(height: 12),
              Text(
                'No growth data available',
                style: TextStyle(color: colors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        );
      }

      // Sort by date ascending for chart
      final entries = List<GrowthEntry>.from(controller.growthEntries);
      entries.sort((a, b) {
        final da = a.parsedDate;
        final db = b.parsedDate;
        if (da == null || db == null) return 0;
        return da.compareTo(db);
      });

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HB Chart
            if (entries.any((e) => e.hbValue != null))
              _ChartSection(
                title: 'Hemoglobin (g/dL)',
                entries: entries,
                getValue: (e) => e.hbValue,
                lineColor: AppColors.doctorGreen,
                colors: colors,
              ),
            const SizedBox(height: 20),
            // Height Chart
            if (entries.any((e) => e.heightCm != null))
              _ChartSection(
                title: 'Height (cm)',
                entries: entries,
                getValue: (e) => e.heightCm,
                lineColor: AppColors.indigo,
                colors: colors,
              ),
            const SizedBox(height: 20),
            // Weight Chart
            if (entries.any((e) => e.weightKg != null))
              _ChartSection(
                title: 'Weight (kg)',
                entries: entries,
                getValue: (e) => e.weightKg,
                lineColor: AppColors.teal,
                colors: colors,
              ),
            const SizedBox(height: 20),
            // Data Table
            _DataTable(entries: entries, colors: colors),
          ],
        ),
      );
    });
  }
}

class _ChartSection extends StatelessWidget {
  final String title;
  final List<GrowthEntry> entries;
  final double? Function(GrowthEntry) getValue;
  final Color lineColor;
  final AppThemeColors colors;

  const _ChartSection({
    required this.title,
    required this.entries,
    required this.getValue,
    required this.lineColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final validEntries = entries.where((e) => getValue(e) != null && e.parsedDate != null).toList();
    if (validEntries.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    for (int i = 0; i < validEntries.length; i++) {
      spots.add(FlSpot(i.toDouble(), getValue(validEntries[i])!));
    }

    final values = spots.map((s) => s.y).toList();
    final minY = (values.reduce((a, b) => a < b ? a : b) * 0.9).floorToDouble();
    final maxY = (values.reduce((a, b) => a > b ? a : b) * 1.1).ceilToDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: ((maxY - minY) / 4).clamp(1, 100),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colors.borderColor,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(0),
                        style: TextStyle(color: colors.textSecondary, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: validEntries.length > 6
                          ? (validEntries.length / 4).ceilToDouble()
                          : 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= validEntries.length) return const SizedBox.shrink();
                        final dt = validEntries[idx].parsedDate!;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('MMM yy').format(dt),
                            style: TextStyle(color: colors.textSecondary, fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: lineColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: lineColor,
                        strokeWidth: 1.5,
                        strokeColor: colors.surfaceColor,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withValues(alpha: 0.08),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt();
                        final entry = validEntries[idx];
                        return LineTooltipItem(
                          '${entry.formattedDate}\n${spot.y.toStringAsFixed(1)}',
                          TextStyle(
                            color: colors.surfaceColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataTable extends StatelessWidget {
  final List<GrowthEntry> entries;
  final AppThemeColors colors;

  const _DataTable({required this.entries, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Growth Data',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                colors.primaryColor.withValues(alpha: 0.05),
              ),
              columnSpacing: 20,
              columns: [
                DataColumn(label: Text('Date', style: _headerStyle(colors))),
                DataColumn(label: Text('HB', style: _headerStyle(colors))),
                DataColumn(label: Text('Ht (cm)', style: _headerStyle(colors))),
                DataColumn(label: Text('Wt (kg)', style: _headerStyle(colors))),
                DataColumn(label: Text('BMI', style: _headerStyle(colors))),
              ],
              rows: entries.map((e) {
                return DataRow(cells: [
                  DataCell(Text(e.formattedDate, style: _cellStyle(colors))),
                  DataCell(Text(e.hbValue?.toStringAsFixed(1) ?? '-', style: _cellStyle(colors))),
                  DataCell(Text(e.heightCm?.toStringAsFixed(1) ?? '-', style: _cellStyle(colors))),
                  DataCell(Text(e.weightKg?.toStringAsFixed(1) ?? '-', style: _cellStyle(colors))),
                  DataCell(Text(e.bmi?.toStringAsFixed(1) ?? '-', style: _cellStyle(colors))),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle(AppThemeColors colors) => TextStyle(
        color: colors.textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      );

  TextStyle _cellStyle(AppThemeColors colors) => TextStyle(
        color: colors.textSecondary,
        fontSize: 12,
      );
}
