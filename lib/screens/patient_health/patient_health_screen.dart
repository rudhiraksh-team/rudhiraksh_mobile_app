import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/controllers/patient_health_controller.dart';

class PatientHealthScreen extends StatelessWidget {
  const PatientHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PatientHealthController());
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: colors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(SolarLinearIcons.heartPulse, color: AppColors.brandRed, size: 22),
            const SizedBox(width: 8),
            Text(
              'My Health',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.growthEntries.isEmpty &&
            controller.ferritinEntries.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: colors.primaryColor),
          );
        }

        final hasGrowth = controller.growthEntries.isNotEmpty;
        final hasFerritin = controller.ferritinEntries.isNotEmpty;

        if (!hasGrowth && !hasFerritin) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(SolarLinearIcons.chartSquare, size: 48, color: colors.textSecondary),
                const SizedBox(height: 12),
                Text(
                  'No health data available yet',
                  style: TextStyle(color: colors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: colors.primaryColor,
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ferritin section
                if (hasFerritin) ...[
                  _FerritinSection(
                    entries: controller.ferritinEntries,
                    colors: colors,
                  ),
                  const SizedBox(height: 20),
                ],
                // Growth section
                if (hasGrowth) ...[
                  _GrowthSection(
                    entries: controller.growthEntries,
                    colors: colors,
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Ferritin Section ──────────────────────────────────────────────────────────

class _FerritinSection extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  final AppThemeColors colors;

  const _FerritinSection({required this.entries, required this.colors});

  @override
  Widget build(BuildContext context) {
    // Sort by date ascending
    final sorted = List<Map<String, dynamic>>.from(entries)
      ..sort((a, b) {
        final da = DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime(2000);
        final db = DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime(2000);
        return da.compareTo(db);
      });

    final valid = sorted.where((e) {
      final v = double.tryParse(e['ferritinValue']?.toString() ?? '');
      return v != null && e['date'] != null;
    }).toList();

    if (valid.length < 2) {
      return _SingleValueCard(
        title: 'Ferritin Level',
        icon: SolarLinearIcons.bagHeart,
        iconColor: AppColors.warning,
        value: valid.isNotEmpty
            ? '${valid.last['ferritinValue']} ng/mL'
            : 'No data',
        colors: colors,
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < valid.length; i++) {
      spots.add(FlSpot(i.toDouble(), double.parse(valid[i]['ferritinValue'].toString())));
    }

    final values = spots.map((s) => s.y).toList();
    final minY = 0.0;
    final maxY = (values.reduce((a, b) => a > b ? a : b) * 1.15).ceilToDouble().clamp(100.0, 10000.0);

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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(SolarLinearIcons.bagHeart, size: 18, color: AppColors.warning),
              ),
              const SizedBox(width: 10),
              Text(
                'Ferritin Trend (ng/mL)',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Normal < 1000  |  Elevated 1000-2500  |  High Risk > 2500',
            style: TextStyle(color: colors.textSecondary, fontSize: 10),
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
                  horizontalInterval: (maxY / 4).clamp(1, 2000),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colors.borderColor,
                    strokeWidth: 1,
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    if (maxY >= 1000)
                      HorizontalLine(
                        y: 1000,
                        color: AppColors.warning.withValues(alpha: 0.5),
                        strokeWidth: 1,
                        dashArray: [6, 4],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topLeft,
                          style: TextStyle(color: AppColors.warning, fontSize: 9),
                          labelResolver: (_) => '1000',
                        ),
                      ),
                    if (maxY >= 2500)
                      HorizontalLine(
                        y: 2500,
                        color: AppColors.error.withValues(alpha: 0.5),
                        strokeWidth: 1,
                        dashArray: [6, 4],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topLeft,
                          style: TextStyle(color: AppColors.error, fontSize: 9),
                          labelResolver: (_) => '2500',
                        ),
                      ),
                  ],
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(color: colors.textSecondary, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: valid.length > 6 ? (valid.length / 4).ceilToDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= valid.length) return const SizedBox.shrink();
                        final dt = DateTime.tryParse(valid[idx]['date'].toString());
                        if (dt == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
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
                    color: AppColors.warning,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.warning,
                        strokeWidth: 1.5,
                        strokeColor: colors.surfaceColor,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.warning.withValues(alpha: 0.08),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt();
                        final dt = DateTime.tryParse(valid[idx]['date'].toString());
                        final dateStr = dt != null ? DateFormat('dd MMM yy').format(dt) : '';
                        return LineTooltipItem(
                          '$dateStr\n${spot.y.toInt()} ng/mL',
                          TextStyle(
                            color: colors.surfaceColor,
                            fontSize: 11,
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

// ── Growth Section ────────────────────────────────────────────────────────────

class _GrowthSection extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  final AppThemeColors colors;

  const _GrowthSection({required this.entries, required this.colors});

  @override
  Widget build(BuildContext context) {
    final sorted = List<Map<String, dynamic>>.from(entries)
      ..sort((a, b) {
        final da = DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime(2000);
        final db = DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime(2000);
        return da.compareTo(db);
      });

    final hasHb = sorted.where((e) => _parseDouble(e['hbValue']) != null).length >= 2;
    final hasHeight = sorted.where((e) => _parseDouble(e['heightCm']) != null).length >= 2;
    final hasWeight = sorted.where((e) => _parseDouble(e['weightKg']) != null).length >= 2;

    if (!hasHb && !hasHeight && !hasWeight) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasHb)
          _GrowthChart(
            title: 'Hemoglobin (g/dL)',
            icon: SolarLinearIcons.heartPulse,
            iconColor: AppColors.brandRed,
            entries: sorted,
            getKey: 'hbValue',
            lineColor: AppColors.brandRed,
            colors: colors,
          ),
        if (hasHb && (hasHeight || hasWeight)) const SizedBox(height: 16),
        if (hasHeight)
          _GrowthChart(
            title: 'Height (cm)',
            icon: SolarLinearIcons.chartSquare,
            iconColor: AppColors.doctorGreen,
            entries: sorted,
            getKey: 'heightCm',
            lineColor: AppColors.doctorGreen,
            colors: colors,
          ),
        if (hasHeight && hasWeight) const SizedBox(height: 16),
        if (hasWeight)
          _GrowthChart(
            title: 'Weight (kg)',
            icon: SolarLinearIcons.chartSquare,
            iconColor: AppColors.teal,
            entries: sorted,
            getKey: 'weightKg',
            lineColor: AppColors.teal,
            colors: colors,
          ),
      ],
    );
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

class _GrowthChart extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Map<String, dynamic>> entries;
  final String getKey;
  final Color lineColor;
  final AppThemeColors colors;

  const _GrowthChart({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.entries,
    required this.getKey,
    required this.lineColor,
    required this.colors,
  });

  double? _parse(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  @override
  Widget build(BuildContext context) {
    final valid = entries.where((e) => _parse(e[getKey]) != null && e['date'] != null).toList();
    if (valid.length < 2) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    for (int i = 0; i < valid.length; i++) {
      spots.add(FlSpot(i.toDouble(), _parse(valid[i][getKey])!));
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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
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
                      reservedSize: 28,
                      interval: valid.length > 6 ? (valid.length / 4).ceilToDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= valid.length) return const SizedBox.shrink();
                        final dt = DateTime.tryParse(valid[idx]['date'].toString());
                        if (dt == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
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
                        final dt = DateTime.tryParse(valid[idx]['date'].toString());
                        final dateStr = dt != null ? DateFormat('dd MMM yy').format(dt) : '';
                        return LineTooltipItem(
                          '$dateStr\n${spot.y.toStringAsFixed(1)}',
                          TextStyle(
                            color: colors.surfaceColor,
                            fontSize: 11,
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

// ── Single Value Card (for < 2 entries) ───────────────────────────────────────

class _SingleValueCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String value;
  final AppThemeColors colors;

  const _SingleValueCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
