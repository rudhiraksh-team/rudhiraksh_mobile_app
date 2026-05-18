import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/controllers/dashboard_controller.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/enums/transfusion_status.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';

class CalendarSection extends StatelessWidget {
  final DashboardController controller;
  const CalendarSection({super.key, required this.controller});

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Obx(() {
      Map<DateTime, List<dynamic>> events = {};

      for (var t in controller.doneTransfusions) {
        if (t.visitDate != null) {
          final key = _stripTime(t.visitDate!);
          events.putIfAbsent(key, () => []).add(t);
        }
      }

      for (var m in controller.missedTransfusions) {
        if (m.expectedDate != null) {
          final key = _stripTime(m.expectedDate!);
          events.putIfAbsent(key, () => []).add(m);
        }
      }

      if (controller.upcomingTransfusion.value != null &&
          controller.upcomingTransfusion.value!.nextTransfusionDate != null) {
        final key = _stripTime(
          controller.upcomingTransfusion.value!.nextTransfusionDate!,
        );
        events
            .putIfAbsent(key, () => [])
            .add(controller.upcomingTransfusion.value!);
      }

      TransfusionStatus? statusForDay(DateTime day) {
        final key = _stripTime(day);

        for (var t in controller.doneTransfusions) {
          if (t.visitDate != null && _stripTime(t.visitDate!) == key) {
            return TransfusionStatus.done;
          }
        }

        for (var m in controller.missedTransfusions) {
          if (m.expectedDate != null && _stripTime(m.expectedDate!) == key) {
            return TransfusionStatus.missed;
          }
        }

        if (controller.upcomingTransfusion.value != null &&
            controller.upcomingTransfusion.value!.nextTransfusionDate != null &&
            _stripTime(
                  controller.upcomingTransfusion.value!.nextTransfusionDate!,
                ) ==
                key) {
          return TransfusionStatus.upcoming;
        }

        return null;
      }

      Color colorForStatus(TransfusionStatus? status) {
        if (status == null) return colors.textSecondary.withValues(alpha: 0.12);
        switch (status) {
          case TransfusionStatus.upcoming:
            return colors.primaryColor;
          case TransfusionStatus.missed:
            return AppColors.error;
          case TransfusionStatus.done:
            return AppColors.success;
        }
      }

      final focused = controller.selectedDate.value ?? DateTime.now();

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12,
          vertical: isSmallScreen ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.borderColor),
        ),
        child: TableCalendar<dynamic>(
          firstDay: DateTime(2024, 1, 1),
          lastDay: DateTime(2030, 12, 31),
          focusedDay: focused,
          availableGestures: AvailableGestures.none,
          selectedDayPredicate: (day) {
            final sd = controller.selectedDate.value;
            if (sd == null) return false;
            return _stripTime(day) == _stripTime(sd);
          },
          eventLoader: (day) => events[_stripTime(day)] ?? [],
          onDaySelected: (selectedDay, focusedDay) {
            controller.onDateSelected(selectedDay);
          },
          calendarFormat: CalendarFormat.month,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              color: colors.textPrimary,
              fontSize: isSmallScreen ? 15 : 17,
              fontWeight: FontWeight.w700,
            ),
            leftChevronIcon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.calendarAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                SolarLinearIcons.altArrowLeft,
                color: AppColors.calendarAccent,
                size: 18,
              ),
            ),
            rightChevronIcon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.calendarAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                SolarLinearIcons.altArrowRight,
                color: AppColors.calendarAccent,
                size: 18,
              ),
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            weekendStyle: TextStyle(
              color: colors.primaryColor.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          calendarStyle: CalendarStyle(
            markerDecoration: const BoxDecoration(),
            todayDecoration: BoxDecoration(
              color: AppColors.calendarAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(),
            outsideDaysVisible: false,
          ),
          calendarBuilders: CalendarBuilders<dynamic>(
            selectedBuilder: (context, date, focusedDay) {
              final status = statusForDay(date);
              final fillColor = colorForStatus(status);
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: fillColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: fillColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              );
            },
            todayBuilder: (context, date, focusedDay) {
              final isSelected = controller.selectedDate.value != null &&
                  _stripTime(controller.selectedDate.value!) ==
                      _stripTime(date);
              if (isSelected) {
                final status = statusForDay(date);
                final fillColor = colorForStatus(status);
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: fillColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: fillColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                );
              }

              final status = statusForDay(date);
              final outlineColor =
                  status != null ? colorForStatus(status) : null;
              return Container(
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.calendarAccent.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: outlineColor != null
                      ? Border.all(color: outlineColor, width: 2)
                      : null,
                ),
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: AppColors.calendarAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              );
            },
            defaultBuilder: (context, date, focusedDay) {
              final isSelected = controller.selectedDate.value != null &&
                  _stripTime(controller.selectedDate.value!) ==
                      _stripTime(date);
              if (isSelected) {
                final status = statusForDay(date);
                final fillColor = colorForStatus(status);
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: fillColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: fillColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                );
              }

              final status = statusForDay(date);
              if (status != null) {
                final outlineColor = colorForStatus(status);
                return Container(
                  margin: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: outlineColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(color: outlineColor, width: 2),
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: outlineColor,
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                );
              }

              return Container(
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              );
            },
            markerBuilder: (context, date, eventsForDay) =>
                const SizedBox.shrink(),
          ),
        ),
      );
    });
  }
}
