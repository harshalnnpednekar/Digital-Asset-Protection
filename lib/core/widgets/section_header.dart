import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     title, 
                     style: AppTextStyles.mono(
                       size: 22, 
                       weight: FontWeight.w700, 
                       color: c.textPrimary,
                     ),
                   ),
                   if (subtitle != null) ...[
                     const SizedBox(height: 4),
                     Text(
                       subtitle!, 
                       style: AppTextStyles.sans(
                         size: 13, 
                         color: c.textSecondary,
                       ),
                     ),
                   ]
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 20),
        Divider(color: c.borderDefault, height: 1, thickness: 1),
        const SizedBox(height: 24),
      ],
    );
  }
}
