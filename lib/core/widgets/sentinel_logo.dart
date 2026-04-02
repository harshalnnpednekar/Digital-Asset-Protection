import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme_colors.dart';

class SentinelLogo extends StatelessWidget {
  final bool isLarge;

  const SentinelLogo({super.key, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final double mainFontSize = isLarge ? 28 : 14;
    final double subFontSize = isLarge ? 10 : 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "SENTINEL",
              style: AppTextStyles.mono(
                size: mainFontSize,
                weight: FontWeight.w700,
                color: AppColors.accentAmber,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "AI",
              style: AppTextStyles.mono(
                size: mainFontSize,
                weight: FontWeight.w700,
                color: c.accentBlue,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        Text(
          "MEDIA PROTECTION PLATFORM",
          style: AppTextStyles.mono(
            size: subFontSize,
            color: c.textMuted,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}
