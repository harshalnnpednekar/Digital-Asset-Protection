import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/widgets/shimmer_box.dart';
import 'dashboard_mock_data.dart';
import 'dashboard_widgets.dart';

class DashboardPlatformsSection extends StatelessWidget {
  final bool loading;
  const DashboardPlatformsSection({super.key, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ThreatOriginPlatformsCard(loading: loading),
        const SizedBox(height: 16),
        _PatientZeroDetectionsCard(loading: loading),
      ],
    );
  }
}

class _ThreatOriginPlatformsCard extends StatelessWidget {
  final bool loading;
  const _ThreatOriginPlatformsCard({this.loading = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: c.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "THREAT ORIGIN PLATFORMS", 
            style: AppTextStyles.display(
              size: 13, 
              weight: FontWeight.w700, 
              color: c.textMuted, 
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            Column(
              children: List.generate(
                  4,
                  (index) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: ShimmerBox(height: 20, width: double.infinity),
                      )),
            )
          else
            ...DashboardMockData.platformStats
                .map((stat) => _PlatformBar(stat: stat)),
        ],
      ),
    );
  }
}

class _PlatformBar extends StatelessWidget {
  final PlatformStat stat;

  const _PlatformBar({required this.stat});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Color barColor;
    switch (stat.platform) {
      case "X (Twitter)":
        barColor = AppColors.accentCrimson;
        break;
      case "Telegram":
        barColor = AppColors.accentAmber;
        break;
      case "YouTube":
        barColor = c.accentBlue;
        break;
      case "Reddit":
        barColor = AppColors.accentPurple;
        break;
      default:
        barColor = c.textMuted;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              stat.platform,
              style:
                  AppTextStyles.body(size: 13, weight: FontWeight.w600, color: c.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 6,
                  color: c.bgTertiary,
                ),
                Animate(
                  effects: [
                    CustomEffect(
                      duration: 800.ms,
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return FractionallySizedBox(
                          widthFactor: (stat.percentage / 100.0) * value,
                          child: Container(
                            height: 6,
                            color: barColor,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              "${stat.percentage.toStringAsFixed(0)}%",
              style: AppTextStyles.display(size: 12, weight: FontWeight.w700, color: c.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientZeroDetectionsCard extends StatelessWidget {
  final bool loading;
  const _PatientZeroDetectionsCard({this.loading = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: c.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PATIENT ZERO DETECTIONS", 
            style: AppTextStyles.display(
              size: 13, 
              weight: FontWeight.w700, 
              color: c.textMuted, 
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            Column(
              children: List.generate(
                  3,
                  (index) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: ShimmerBox(height: 48, width: double.infinity),
                      )),
            )
          else
            ...DashboardMockData.recentDetections
                .map((detection) => _DetectionRow(detection: detection)),
        ],
      ),
    );
  }
}

class _DetectionRow extends StatelessWidget {
  final PatientZeroDetection detection;

  const _DetectionRow({required this.detection});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: c.borderDefault, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            color: AppColors.accentCrimson,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detection.partnerName,
                  style: AppTextStyles.body(
                    size: 13,
                    weight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detection.assetName,
                  style:
                      AppTextStyles.body(size: 11, color: c.textMuted, weight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const CustomChip(label: "IDENTIFIED", color: AppColors.accentCrimson),
        ],
      ),
    );
  }
}
