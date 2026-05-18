import 'package:flutter/material.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';

import '../../../core/theme/app_theme_colors.dart';

/// Card chrome for one read-only profile section.
///
/// Shows an icon + title header, optionally a lock badge (for non-editable
/// sections) or an edit pen (for sections that route to a dedicated edit
/// screen), and renders the provided rows beneath.
class ProfileSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> rows;
  final Color accentColor;
  final bool locked;
  final VoidCallback? onEdit;

  const ProfileSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.rows,
    required this.accentColor,
    this.locked = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderColor),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (locked)
                Icon(
                  SolarLinearIcons.lock,
                  size: 14,
                  color: colors.textSecondary.withValues(alpha: 0.5),
                ),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      SolarLinearIcons.pen,
                      size: 16,
                      color: accentColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...rows,
        ],
      ),
    );
  }
}

/// One label/value row inside a [ProfileSectionCard].
class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colors.textSecondary.withValues(alpha: 0.6)),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
