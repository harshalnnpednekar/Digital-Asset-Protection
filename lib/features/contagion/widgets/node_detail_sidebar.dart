import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/widgets/custom_chip.dart';
import '../../../core/widgets/scale_button.dart';
import '../contagion_mock_data.dart';

class NodeDetailSidebar extends StatelessWidget {
  final ContagionNode? node;
  final ContagionNode? parentNode;
  final int childCount;

  final VoidCallback? onClose;

  const NodeDetailSidebar({
    super.key,
    this.node,
    this.parentNode,
    this.childCount = 0,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: c.isDark ? c.bgSecondary : c.bgPrimary,
        border: Border(left: BorderSide(color: c.borderDefault)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(-4, 0),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.borderDefault)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(PhosphorIcons.fingerprint(), size: 14, color: AppColors.accentAmber),
                    const SizedBox(width: 8),
                    Text(
                      "FORENSIC INSPECTION", 
                      style: AppTextStyles.mono(
                        size: 11, 
                        weight: FontWeight.w600, 
                        color: c.textMuted, 
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                if (onClose != null)
                  IconButton(
                    icon: Icon(PhosphorIcons.x(), size: 16),
                    onPressed: onClose,
                    visualDensity: VisualDensity.compact,
                    color: c.textMuted,
                  ),
              ],
            ),
          ),

          Expanded(
            child: node == null
                ? const SizedBox()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TIER BADGE
                        CustomChip(
                          label: node!.tier == 'ROOT' ? 'PATIENT ZERO' : 'TIER ${node!.tier.substring(1)}',
                          color: _getTierColor(node!.tier, c),
                        ),
                        const SizedBox(height: 16),
                        
                        Text(
                          node!.label,
                          style: AppTextStyles.mono(size: 15, weight: FontWeight.w700, color: c.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        _PlatformBadge(platform: node!.platform),
                        
                        const SizedBox(height: 24),
                        Text("NETWORK SIGNATURE", 
                            style: AppTextStyles.mono(size: 10, color: c.textMuted, weight: FontWeight.w700, letterSpacing: 1)),
                        const SizedBox(height: 12),
                        
                        _ForensicRow(label: "IP ADDRESS", value: node!.ipAddress, isPrimary: true),
                        _ForensicRow(label: "SOURCE URL", value: node!.sourceUrl),
                        _ForensicRow(label: "DETECTED AT", value: node!.detectedAt),
                        _ForensicRow(label: "EST. REACH", value: node!.estimatedReach),
                        
                        const SizedBox(height: 20),
                        Divider(color: c.borderDefault),
                        const SizedBox(height: 20),
                        
                        Text("HIERARCHY POSITION", 
                            style: AppTextStyles.mono(size: 10, color: c.textMuted, weight: FontWeight.w700, letterSpacing: 1)),
                        const SizedBox(height: 12),
                        
                        _ForensicRow(label: "PARENT NODE", value: parentNode?.label ?? "ORIGIN SOURCE"),
                        _ForensicRow(label: "CHILD NODES", value: "$childCount downstream entities"),
                        
                        const SizedBox(height: 32),
                        
                        if (node!.tier != 'ROOT') ...[
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ScaleButton(
                              onTap: () {},
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentCrimson.withValues(alpha: 0.8),
                                  foregroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  elevation: 0,
                                ),
                                onPressed: () {}, 
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(PhosphorIcons.hammer(), size: 16),
                                    const SizedBox(width: 12),
                                    Text(
                                      "ISSUE DMCA TAKEDOWN",
                                      style: AppTextStyles.mono(size: 11, weight: FontWeight.w700, letterSpacing: 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ScaleButton(
                            onTap: () {},
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: c.borderDefault),
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              ),
                              onPressed: () {}, 
                              child: Text(
                                "CLIP EVIDENCE LOG",
                                style: AppTextStyles.mono(size: 11, weight: FontWeight.w600, color: c.textSecondary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate(key: ValueKey(node!.id)).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String tier, AppThemeColors c) {
    switch (tier) {
      case 'ROOT': return AppColors.accentCrimson;
      case 'T1': return AppColors.accentAmber;
      default: return c.accentBlue;
    }
  }
}

class _ForensicRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrimary;

  const _ForensicRow({required this.label, required this.value, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.mono(size: 9, color: c.textMuted, weight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: c.bgTertiary,
              border: Border.all(color: c.borderDefault),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              value, 
              style: AppTextStyles.mono(
                size: isPrimary ? 13 : 11, 
                weight: isPrimary ? FontWeight.w700 : FontWeight.w500, 
                color: isPrimary ? AppColors.accentAmber : c.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
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
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.accentBlue.withValues(alpha: 0.1),
        border: Border.all(color: c.accentBlue.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIcons.cube(), size: 10, color: c.accentBlue),
          const SizedBox(width: 6),
          Text(
            platform.toUpperCase(),
            style: AppTextStyles.mono(size: 9, weight: FontWeight.w800, color: c.accentBlue),
          ),
        ],
      ),
    );
  }
}
