import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/widgets/shimmer_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_mock_data.dart';
import 'dashboard_widgets.dart';

class DashboardTimelineSection extends StatelessWidget {
  final bool loading;
  const DashboardTimelineSection({super.key, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    
    return Container(
      decoration: c.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Text(
                  "THREAT ACTIVITY", 
                  style: AppTextStyles.mono(
                    size: 13, 
                    weight: FontWeight.w700, 
                    color: c.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const StatusDot(color: AppColors.accentGreen, size: 6),
                    const SizedBox(width: 6),
                    Text(
                      "Live",
                      style: AppTextStyles.display(
                        size: 12,
                        color: AppColors.accentGreen,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('threat_alerts').orderBy('detected_at', descending: true).limit(8).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: List.generate(
                          6,
                          (index) => const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: ShimmerBox(height: 60, width: double.infinity),
                              )),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text("No threat activity recorded.")),
                  );
                }
                
                final docs = snapshot.data!.docs;
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    String formatTimeAgo(DateTime dt) {
                      final diff = DateTime.now().difference(dt);
                      if (diff.inSeconds < 60) return "${diff.inSeconds}s ago";
                      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
                      if (diff.inHours < 24) return "${diff.inHours}h ago";
                      return "${diff.inDays}d ago";
                    }
                    
                    final item = ThreatTimelineItem(
                      assetName: data['matched_asset_name'] ?? 'Unknown',
                      platform: data['platform'] ?? 'Unknown',
                      matchPercent: ((data['visual_similarity'] ?? 0.0) * 100).toStringAsFixed(1),
                      timestamp: data['detected_at'] != null ? formatTimeAgo((data['detected_at'] as Timestamp).toDate()) : 'Just now',
                      status: data['status'] ?? 'ACTIVE',
                    );
                    
                    return _TimelineItemTile(item: item);
                  },
                );
              }
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
    final c = context.colors;
    Color statusColor;
    switch (item.status) {
      case 'ACTIVE':
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
      matchColor = c.textMuted;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 3, color: statusColor),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                    bottom:
                        BorderSide(color: c.borderDefault, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                            item.assetName,
                            style: AppTextStyles.body(
                              size: 14,
                              weight: FontWeight.w600,
                              color: c.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              item.timestamp,
                              style: AppTextStyles.body(
                                size: 12, 
                                color: c.textMuted,
                                weight: FontWeight.w500,
                              ),
                            ),
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
                        "${item.matchPercent}% Match",
                        style: AppTextStyles.display(
                          size: 14,
                          weight: FontWeight.w700,
                          color: matchColor,
                        ),
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
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: c.borderDefault, width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        platform.toUpperCase(),
        style: AppTextStyles.display(
          size: 9, 
          weight: FontWeight.w700,
          color: c.textMuted, 
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
