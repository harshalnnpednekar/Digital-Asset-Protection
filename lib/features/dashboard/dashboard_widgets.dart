import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_colors.dart';

class StatusDot extends StatelessWidget {
  final Color color;
  final double size;

  const StatusDot({
    super.key,
    required this.color,
    this.size = 7.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(102),
            blurRadius: size * 2,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class CustomChip extends StatelessWidget {
  final String label;
  final Color color;

  const CustomChip({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        border: Border.all(color: color.withAlpha(77)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.body(
          size: 11,
          weight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String name;

  const StatusBadge(this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const StatusDot(color: AppColors.accentGreen, size: 5),
        const SizedBox(width: 5),
        Text(
          name,
          style: AppTextStyles.body(size: 11, color: c.textMuted, weight: FontWeight.w500),
        ),
      ],
    );
  }
}

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    
    // Calculate IST (UTC + 5:30)
    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    final dateStr = '${now.day.toString().padLeft(2, '0')} ${_getMonthName(now.month)} ${now.year}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} IST';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "OPERATIONAL OVERVIEW",
              style: AppTextStyles.display(
                size: 13,
                weight: FontWeight.w800,
                color: c.accentBlue,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const StatusDot(color: AppColors.accentGreen, size: 8),
                const SizedBox(width: 10),
                Text(
                  "All protection systems operational",
                  style: AppTextStyles.body(
                    size: 14,
                    weight: FontWeight.w500,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              dateStr.toUpperCase(),
              style: AppTextStyles.display(
                size: 12,
                weight: FontWeight.w700,
                color: c.textMuted,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: AppTextStyles.mono(
                size: 20,
                weight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }
}
