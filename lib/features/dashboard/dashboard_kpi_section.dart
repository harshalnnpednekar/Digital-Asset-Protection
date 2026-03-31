import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shimmer_box.dart';

class DashboardKpiSection extends StatelessWidget {
  final bool loading;
  const DashboardKpiSection({super.key, this.loading = false});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Row(
        children: List.generate(4, (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 3 ? 0 : 16),
            child: const ShimmerBox(height: 140, width: double.infinity),
          ),
        )),
      );
    }

    return Row(
      children: [
        // ... (existing cards)
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

class _KpiCard extends StatefulWidget {
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
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget bottomStrip = Container(
      height: 3,
      width: double.infinity,
      color: widget.accentColor.withAlpha(153),
    );

    if (widget.isPulsing) {
      bottomStrip = bottomStrip.animate(onPlay: (c) => c.repeat()).shimmer(
        duration: 2000.ms,
        color: widget.accentColor.withAlpha(77),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          border: Border.all(
            color: _isHovered ? widget.accentColor.withAlpha(102) : AppColors.borderDefault,
          ),
          boxShadow: _isHovered 
            ? [BoxShadow(color: widget.accentColor.withAlpha(26), blurRadius: 10, spreadRadius: -2)] 
            : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top highlight on hover
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: double.infinity,
              color: _isHovered ? widget.accentColor : Colors.transparent,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.label, style: AppTextStyles.sectionLabel),
                        const SizedBox(height: 8),
                        Text(
                          widget.value,
                          style: AppTextStyles.kpiNumber.copyWith(color: widget.valueColor),
                        ),
                        const SizedBox(height: 4),
                        Text(widget.sublabel, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withAlpha(26),
                      border: Border.all(color: widget.accentColor, width: 1),
                    ),
                    child: Center(
                      child: Icon(widget.icon, color: widget.accentColor, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            bottomStrip,
          ],
        ),
      ),
    );
  }
}
