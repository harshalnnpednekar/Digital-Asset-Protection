import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class DashboardKpiSection extends StatelessWidget {
  const DashboardKpiSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: "ASSETS VAULTED",
            value: "247",
            valueColor: AppColors.textPrimary,
            sublabel: "↑ 12 secured this week",
            icon: PhosphorIcons.shieldCheck(),
            accentColor: AppColors.accentBlue,
            index: 0,
          ).animate().fadeIn(delay: 0.ms, duration: 400.ms).slideY(begin: 0.15, end: 0),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiCard(
            label: "ACTIVE THREATS",
            value: "7",
            valueColor: AppColors.accentCrimson,
            sublabel: "Requires immediate action",
            icon: PhosphorIcons.warning(),
            accentColor: AppColors.accentCrimson,
            isPulsing: true,
            index: 1,
          ).animate().fadeIn(delay: 80.ms, duration: 400.ms).slideY(begin: 0.15, end: 0),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiCard(
            label: "SCANS COMPLETED",
            value: "14,382",
            valueColor: AppColors.textPrimary,
            sublabel: "↑ 2,104 in last 24 hours",
            icon: PhosphorIcons.broadcast(),
            accentColor: AppColors.accentAmber,
            index: 2,
          ).animate().fadeIn(delay: 160.ms, duration: 400.ms).slideY(begin: 0.15, end: 0),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiCard(
            label: "PRECISION RATE",
            value: "98.1%",
            valueColor: AppColors.accentGreen,
            sublabel: "1,204 false positives removed",
            icon: PhosphorIcons.checkCircle(),
            accentColor: AppColors.accentGreen,
            index: 3,
          ).animate().fadeIn(delay: 240.ms, duration: 400.ms).slideY(begin: 0.15, end: 0),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final String sublabel;
  final IconData icon;
  final Color accentColor;
  final bool isPulsing;
  final int index;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.sublabel,
    required this.icon,
    required this.accentColor,
    this.isPulsing = false,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    Widget bottomStrip = Container(
      height: 3,
      width: double.infinity,
      color: accentColor.withAlpha(153),
    );

    if (isPulsing) {
      bottomStrip = bottomStrip.animate(onPlay: (c) => c.repeat()).shimmer(
        duration: 2000.ms,
        color: accentColor.withAlpha(77),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppTextStyles.sectionLabel),
                      const SizedBox(height: 8),
                      Text(
                        value,
                        style: AppTextStyles.kpiNumber.copyWith(color: valueColor),
                      ),
                      const SizedBox(height: 4),
                      Text(sublabel, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(26),
                    border: Border.all(color: accentColor, width: 1),
                  ),
                  child: Center(
                    child: Icon(icon, color: accentColor, size: 24),
                  ),
                ),
              ],
            ),
          ),
          bottomStrip,
        ],
      ),
    );
  }
}
