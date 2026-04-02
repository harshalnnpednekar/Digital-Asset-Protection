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

class DashboardStatusBar extends StatelessWidget {
  const DashboardStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final now = DateTime.now().toUtc();
    final timestamp = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} UTC';

    return Container(
      height: 44,
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.bgSecondary,
        border: Border.all(color: c.borderDefault),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // LEFT
          Row(
            children: [
              const StatusDot(color: AppColors.accentGreen, size: 7),
              const SizedBox(width: 8),
              Text(
                "System Status: All services operational",
                style: AppTextStyles.body(
                  size: 13,
                  color: AppColors.accentGreen,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          // CENTER
          Expanded(
            child: Center(
              child: Text(
                "Sentinel AI Dashboard  •  Session Active  •  $timestamp",
                style: AppTextStyles.body(
                  size: 11,
                  color: c.textMuted,
                  weight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          // RIGHT
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusBadge("HF API"),
              SizedBox(width: 16),
              StatusBadge("GEMINI"),
              SizedBox(width: 16),
              StatusBadge("FIREBASE"),
            ],
          ),
        ],
      ),
    );
  }
}
