import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SentinelLogo extends StatelessWidget {
  final bool isLarge;

  const SentinelLogo({super.key, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    final double mainFontSize = isLarge ? 28 : 18;
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
                color: AppColors.accentBlue,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        Text(
          "MEDIA PROTECTION PLATFORM",
          style: AppTextStyles.mono(
            size: subFontSize,
            color: AppColors.textMuted,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}
