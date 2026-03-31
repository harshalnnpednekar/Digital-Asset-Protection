import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'dashboard_mock_data.dart';
import 'dashboard_widgets.dart';

class DashboardPlatformsSection extends StatelessWidget {
  const DashboardPlatformsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ThreatOriginPlatformsCard(),
        const SizedBox(height: 16),
        _PatientZeroDetectionsCard(),
      ],
    );
  }
}

class _ThreatOriginPlatformsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("THREAT ORIGIN PLATFORMS", style: AppTextStyles.sectionLabel),
          const SizedBox(height: 16),
          // TODO: REPLACE WITH FIRESTORE STREAM
          ...DashboardMockData.platformStats.map((stat) => _PlatformBar(stat: stat)).toList(),
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
    Color barColor;
    switch (stat.platform) {
      case "X (Twitter)":
        barColor = AppColors.accentCrimson;
        break;
      case "Telegram":
        barColor = AppColors.accentAmber;
        break;
      case "YouTube":
        barColor = AppColors.accentBlue;
        break;
      case "Reddit":
        barColor = AppColors.accentPurple;
        break;
      default:
        barColor = AppColors.textMuted;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              stat.platform,
              style: AppTextStyles.sans(size: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 6,
                  color: AppColors.bgTertiary,
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
              style: AppTextStyles.mono(size: 11, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientZeroDetectionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PATIENT ZERO DETECTIONS", style: AppTextStyles.sectionLabel),
          const SizedBox(height: 16),
          // TODO: REPLACE WITH FIRESTORE STREAM
          ...DashboardMockData.recentDetections.map((detection) => _DetectionRow(detection: detection)).toList(),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderDefault, width: 1)),
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
                  style: AppTextStyles.sans(
                    size: 12,
                    weight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detection.assetName,
                  style: AppTextStyles.mono(size: 10, color: AppColors.textMuted),
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
