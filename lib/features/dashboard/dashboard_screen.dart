import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/section_header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: "SYSTEM DASHBOARD", subtitle: "Overview of operation status and active modules"),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.clock(), size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text("[ MODULE PENDING BUILD ]", style: AppTextStyles.mono(size: 14, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    Text("This screen will be built in a subsequent module.", style: AppTextStyles.sans(size: 13, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
