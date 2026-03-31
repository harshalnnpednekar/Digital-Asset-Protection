import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_chip.dart';
import '../contagion_mock_data.dart';

class NodeDetailSidebar extends StatelessWidget {
  final ContagionNode? node;
  final ContagionNode? parentNode;
  final int childCount;

  const NodeDetailSidebar({
    super.key,
    this.node,
    this.parentNode,
    this.childCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(left: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
            ),
            child: Text("NODE DETAILS", style: AppTextStyles.sectionLabel),
          ),

          Expanded(
            child: node == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Tap any node on the\ngraph to inspect it.",
                        style: AppTextStyles.sans(size: 13, color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TIER BADGE
                        CustomChip(
                          label: node!.tier == 'ROOT' ? 'PATIENT ZERO' : 'TIER ${node!.tier.substring(1)}',
                          color: _getTierColor(node!.tier),
                        ),
                        const SizedBox(height: 12),
                        
                        Text(
                          node!.label,
                          style: AppTextStyles.mono(size: 13, weight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        _PlatformBadge(platform: node!.platform),
                        
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.borderDefault),
                        const SizedBox(height: 16),
                        
                        _DetailRow(label: "DETECTED AT", value: node!.detectedAt),
                        _DetailRow(label: "EST. REACH", value: node!.estimatedReach),
                        _DetailRow(label: "PLATFORM", value: node!.platform),
                        _DetailRow(label: "PARENT NODE", value: parentNode?.label ?? "—"),
                        _DetailRow(label: "CHILD NODES", value: "$childCount downstream"),
                        
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.borderDefault),
                        const SizedBox(height: 24),
                        
                        if (node!.tier != 'ROOT') ...[
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentAmber,
                                foregroundColor: AppColors.textOnAmber,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                elevation: 0,
                              ),
                              onPressed: () {},
                              child: Text(
                                "GENERATE DMCA FOR\nTHIS NODE",
                                style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, letterSpacing: 1),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.borderDefault),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            onPressed: () {},
                            child: Text(
                              "COPY EVIDENCE URL",
                              style: AppTextStyles.sans(size: 11, weight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ).animate(key: ValueKey(node!.id)).fadeIn(duration: 200.ms).slideX(begin: 0.1, end: 0),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'ROOT': return AppColors.accentCrimson;
      case 'T1': return AppColors.accentAmber;
      case 'T2': return AppColors.accentBlue;
      default: return AppColors.accentPurple;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.mono(size: 9, color: AppColors.textMuted, letterSpacing: 2)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.sans(size: 12, weight: FontWeight.w500, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _PlatformBadge extends StatelessWidget {
  final String platform;
  const _PlatformBadge({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        border: Border.all(color: AppColors.borderDefault),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        platform.toUpperCase(),
        style: AppTextStyles.mono(size: 8, weight: FontWeight.w600, color: AppColors.textSecondary),
      ),
    );
  }
}
