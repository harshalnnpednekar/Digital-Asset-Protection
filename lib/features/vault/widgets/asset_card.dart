import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../vault_mock_data.dart';

class AssetCard extends StatefulWidget {
  final VaultedAsset asset;

  const AssetCard({
    super.key,
    required this.asset,
  });

  @override
  State<AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color categoryColor;
    switch (widget.asset.category) {
      case 'HIGHLIGHT':
        categoryColor = AppColors.accentAmber;
        break;
      case 'PRESS_CONF':
        categoryColor = AppColors.accentBlue;
        break;
      case 'TRAINING':
        categoryColor = AppColors.accentGreen;
        break;
      case 'PROMO':
        categoryColor = AppColors.accentPurple;
        break;
      default:
        categoryColor = AppColors.textMuted;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          border: Border.all(
            color: _isHovered 
                ? AppColors.borderDefault.withAlpha(204) // 0.8 opacity approx
                : AppColors.borderDefault,
            width: 1,
          ),
          boxShadow: _isHovered ? [
            BoxShadow(
              color: AppColors.accentBlue.withAlpha(20), // 0.08 opacity approx
              blurRadius: 16,
              spreadRadius: 0,
            )
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // THUMBNAIL AREA
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.bgTertiary,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIcons.videoCamera(),
                            size: 32,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.asset.category,
                            style: AppTextStyles.sectionLabel,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // TOP-LEFT: C2PA
                  if (widget.asset.c2paSecured)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: AnimatedScale(
                        scale: _isHovered ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: _CardBadge(
                          label: "C2PA SECURED",
                          color: AppColors.accentBlue,
                          icon: PhosphorIcons.lock(),
                        ),
                      ),
                    ),
                  
                  // TOP-RIGHT: CATEGORY
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _CardBadge(
                      label: widget.asset.category,
                      color: categoryColor,
                    ),
                  ),
                  
                  // BOTTOM INDICATOR
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: widget.asset.status == 'PROCESSING'
                        ? SizedBox(
                            height: 3,
                            child: LinearProgressIndicator(
                              value: widget.asset.vectorizationProgress,
                              backgroundColor: AppColors.bgPrimary,
                              valueColor: const AlwaysStoppedAnimation(AppColors.accentAmber),
                            ),
                          )
                        : Container(
                            height: 3,
                            color: widget.asset.status == 'VAULTED' 
                                ? AppColors.accentGreen 
                                : AppColors.accentCrimson,
                          ),
                  ),
                ],
              ),
            ),
            
            // CARD BODY
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.asset.name,
                    style: AppTextStyles.sans(
                      size: 13,
                      weight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.asset.uploadDate,
                        style: AppTextStyles.mono(size: 10, color: AppColors.textMuted),
                      ),
                      Text(
                        widget.asset.duration,
                        style: AppTextStyles.mono(size: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.asset.fileSize,
                    style: AppTextStyles.mono(size: 10, color: AppColors.textMuted),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // DISTRIBUTION TARGET
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentCrimson.withAlpha(13), // 0.05 opacity
                      border: const Border(
                        left: BorderSide(color: AppColors.accentCrimson, width: 3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIcons.userFocus(),
                          size: 10,
                          color: AppColors.accentCrimson,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.asset.distributionTarget,
                            style: AppTextStyles.mono(
                              size: 10,
                              weight: FontWeight.w600,
                              color: AppColors.accentCrimson,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.borderDefault, height: 1),
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _IconTextButton(
                        icon: PhosphorIcons.eye(),
                        label: "Details",
                      ),
                      _IconTextButton(
                        icon: PhosphorIcons.fileText(),
                        label: "DMCA",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _CardBadge({
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26), // 0.1 opacity approx
        border: Border.all(color: color.withAlpha(77)), // 0.3 opacity approx
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.mono(
              size: 10,
              weight: FontWeight.w600,
              color: color,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconTextButton extends StatefulWidget {
  final IconData icon;
  final String label;

  const _IconTextButton({
    required this.icon,
    required this.label,
  });

  @override
  State<_IconTextButton> createState() => _IconTextButtonState();
}

class _IconTextButtonState extends State<_IconTextButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = _isHovered ? AppColors.accentAmber : AppColors.textMuted;

    return InkWell(
      onTap: () {},
      onHover: (hovering) => setState(() => _isHovered = hovering),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              widget.label,
              style: AppTextStyles.mono(
                size: 10,
                weight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
