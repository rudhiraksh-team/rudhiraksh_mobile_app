import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/data/models/transfusion_list_model.dart';

class TransfusionCharts extends StatelessWidget {
  final List<Transfusion> records;

  const TransfusionCharts({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    // Filter completed transfusions with valid dates, sorted ascending
    final completed = records
        .where((r) => r.id != null && r.visitDate != null)
        .toList()
      ..sort((a, b) => a.visitDate!.compareTo(b.visitDate!));

    if (completed.length < 2) return const SizedBox.shrink();

    final hbEntries = completed.where((r) => r.preHb != null).toList();
    final volEntries = completed.where((r) => r.volumeMl != null && r.volumeMl! > 0).toList();

    if (hbEntries.length < 2 && volEntries.length < 2) return const SizedBox.shrink();

    return Column(
      children: [
        if (hbEntries.length >= 2)
          _HbTrendChart(entries: hbEntries, colors: colors),
        if (hbEntries.length >= 2 && volEntries.length >= 2)
          const SizedBox(height: 12),
        if (volEntries.length >= 2)
          _VolumeTrendChart(entries: volEntries, colors: colors),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _HbTrendChart extends StatelessWidget {
  final List<Transfusion> entries;
  final AppThemeColors colors;

  const _HbTrendChart({required this.entries, required this.colors});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (int i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].preHb!));
    }

    final values = spots.map((s) => s.y).toList();
    final minY = (values.reduce((a, b) => a < b ? a : b) * 0.85).floorToDouble();
    final maxY = (values.reduce((a, b) => a > b ? a : b) * 1.15).ceilToDouble();

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
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.brandRed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Hemoglobin Trend (g/dL)',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
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
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(1),
                        style: TextStyle(color: colors.textSecondary, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: entries.length > 6
                          ? (entries.length / 4).ceilToDouble()
                          : 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('MMM yy').format(entries[idx].visitDate!),
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
                    color: AppColors.brandRed,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.brandRed,
                        strokeWidth: 1.5,
                        strokeColor: colors.surfaceColor,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.brandRed.withValues(alpha: 0.08),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt();
                        final entry = entries[idx];
                        return LineTooltipItem(
                          '${DateFormat('dd MMM yy').format(entry.visitDate!)}\n${spot.y.toStringAsFixed(1)} g/dL',
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

class _VolumeTrendChart extends StatelessWidget {
  final List<Transfusion> entries;
  final AppThemeColors colors;

  const _VolumeTrendChart({required this.entries, required this.colors});

  @override
  Widget build(BuildContext context) {
    final maxVol = entries.map((e) => e.volumeMl!.toDouble()).reduce((a, b) => a > b ? a : b);

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
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.indigo,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Transfusion Volume (mL)',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxVol * 1.2,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxVol / 4).clamp(1, 1000),
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
                        value.toInt().toString(),
                        style: TextStyle(color: colors.textSecondary, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('MMM yy').format(entries[idx].visitDate!),
                            style: TextStyle(color: colors.textSecondary, fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(entries.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: entries[i].volumeMl!.toDouble(),
                        color: AppColors.indigo,
                        width: entries.length > 10 ? 8 : 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final entry = entries[group.x];
                      return BarTooltipItem(
                        '${DateFormat('dd MMM yy').format(entry.visitDate!)}\n${rod.toY.toInt()} mL',
                        TextStyle(
                          color: colors.surfaceColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
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
