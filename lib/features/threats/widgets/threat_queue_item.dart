import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_chip.dart';
import '../threats_mock_data.dart';

class ThreatQueueItem extends StatefulWidget {
  final ThreatAlert threat;
  final bool isSelected;
  final VoidCallback onTap;

  const ThreatQueueItem({
    super.key,
    required this.threat,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<ThreatQueueItem> createState() => _ThreatQueueItemState();
}

class _ThreatQueueItemState extends State<ThreatQueueItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color statusBarColor;
    switch (widget.threat.geminiIntent) {
      case 'PIRACY':
        statusBarColor = AppColors.accentCrimson;
        break;
      case 'REVIEWING':
        statusBarColor = AppColors.accentAmber;
        break;
      case 'FAIR_USE':
        statusBarColor = AppColors.accentGreen;
        break;
      default:
        statusBarColor = AppColors.textMuted;
    }

    // Override for filed DMCA
    if (widget.threat.status == 'DMCA_FILED') {
      statusBarColor = AppColors.accentBlue;
    } else if (widget.threat.status == 'DISMISSED') {
      statusBarColor = AppColors.accentGreen;
    }

    Color matchColor;
    if (widget.threat.visualSimilarity > 0.85) {
      matchColor = AppColors.accentCrimson;
    } else if (widget.threat.visualSimilarity > 0.65) {
      matchColor = AppColors.accentAmber;
    } else {
      matchColor = AppColors.textMuted;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? AppColors.bgTertiary 
                : (_isHovered ? AppColors.bgOverlay : Colors.transparent),
            border: Border(
              bottom: const BorderSide(color: AppColors.borderDefault),
              right: widget.isSelected 
                  ? const BorderSide(color: AppColors.accentAmber, width: 3)
                  : BorderSide.none,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // LEFT INDICATOR
                Container(
                  width: 3,
                  color: statusBarColor,
                ),
                
                // MAIN CONTENT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // THUMBNAIL PLACEHOLDER
                        Container(
                          width: 64,
                          height: 36,
                          color: AppColors.bgTertiary,
                          child: Center(
                            child: Icon(
                              PhosphorIcons.videoCamera(),
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // DETAILS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.threat.matchedAssetName,
                                      style: AppTextStyles.sans(
                                        size: 12,
                                        weight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // CHEVRON REVEAL
                                  AnimatedOpacity(
                                    opacity: _isHovered ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      PhosphorIcons.caretRight(),
                                      size: 14,
                                      color: AppColors.accentAmber,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _PlatformBadge(platform: widget.threat.platform),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.threat.detectionTime,
                                    style: AppTextStyles.mono(size: 10, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    "${(widget.threat.visualSimilarity * 100).toStringAsFixed(1)}% VISUAL",
                                    style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: matchColor),
                                  ),
                                  const SizedBox(width: 10),
                                  CustomChip(
                                    label: widget.threat.geminiIntent,
                                    color: statusBarColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
