import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shimmer_box.dart';
import 'dashboard_mock_data.dart';
import 'dashboard_widgets.dart';

class DashboardTimelineSection extends StatelessWidget {
  final bool loading;
  const DashboardTimelineSection({super.key, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Text("LIVE THREAT TIMELINE", style: AppTextStyles.sectionLabel),
                const Spacer(),
                const Row(
                  children: [
                    StatusDot(color: AppColors.accentGreen, size: 6),
                    SizedBox(width: 6),
                    Text(
                      "LIVE",
                      style: TextStyle(
                        fontFamily: 'IBM Plex Mono',
                        fontSize: 10,
                        color: AppColors.accentGreen,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: List.generate(6, (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: const ShimmerBox(height: 60, width: double.infinity),
                )),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: DashboardMockData.timelineEvents.length,
              itemBuilder: (context, index) {
                return _TimelineItemTile(item: DashboardMockData.timelineEvents[index]);
              },
            ),
        ],
      ),
    );
  }
}

class _TimelineItemTile extends StatelessWidget {
  final ThreatTimelineItem item;

  const _TimelineItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (item.status) {
      case 'PIRACY':
        statusColor = AppColors.accentCrimson;
        break;
      case 'REVIEWING':
        statusColor = AppColors.accentAmber;
        break;
      default:
        statusColor = AppColors.accentGreen;
    }

    double matchNum = double.tryParse(item.matchPercent) ?? 0;
    Color matchColor;
    if (matchNum > 85) {
      matchColor = AppColors.accentCrimson;
    } else if (matchNum > 60) {
      matchColor = AppColors.accentAmber;
    } else {
      matchColor = AppColors.textMuted;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 3, color: statusColor),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderDefault, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.assetName,
                          style: AppTextStyles.sans(
                            size: 13,
                            weight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(item.timestamp, style: AppTextStyles.mono(size: 10, color: AppColors.textMuted)),
                            const SizedBox(width: 8),
                            _PlatformChip(platform: item.platform),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${item.matchPercent}% MATCH",
                        style: AppTextStyles.mono(size: 11, weight: FontWeight.w700, color: matchColor),
                      ),
                      const SizedBox(height: 6),
                      CustomChip(label: item.status, color: statusColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformChip extends StatelessWidget {
  final String platform;

  const _PlatformChip({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderDefault, width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        platform.toUpperCase(),
        style: AppTextStyles.mono(size: 9, color: AppColors.textMuted, letterSpacing: 1),
      ),
    );
  }
}
