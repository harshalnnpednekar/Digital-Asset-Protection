import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme_colors.dart';
import 'scale_button.dart';

class JudgeGuideModal extends StatelessWidget {
  const JudgeGuideModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(204),
      builder: (context) => const JudgeGuideModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Center(
      child: Container(
        width: 600,
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(
          color: c.bgSecondary,
          border: Border.all(color: c.borderDefault),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: c.borderDefault)),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.bookOpen(), color: c.accentBlue, size: 24),
                  const SizedBox(width: 12),
                    Text(
                      "Operations Manual",
                      style: AppTextStyles.display(
                        size: 20,
                        weight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(PhosphorIcons.x(), size: 14),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // CONTENT
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GuideSection(
                      icon: PhosphorIcons.sparkle(),
                      title: "The Value Proposition",
                      content:
                          "ASTRA provides institutional-grade digital asset protection for sports media. We combine C2PA cryptographic manifests with invisible steganographic watermarking to ensure every frame of your content is authenticated and traceable, even after aggressive re-distribution.",
                    ),
                    const SizedBox(height: 32),
                    _GuideSection(
                      icon: PhosphorIcons.playCircle(),
                      title: "Operational Mission Protocol",
                      content:
                          "• Asset Vault: View high-value masters secured with C2PA metadata.\n• Threat Radar: Monitor real-time neural-engine matches for unauthorized streams.\n• Analysis Deep-dive: Use Gemini AI to differentiate between piracy and fair-use.\n• Propagation Map: Trace the origin and viral spread of content leaks.",
                    ),
                    const SizedBox(height: 32),
                    _GuideSection(
                      icon: PhosphorIcons.lightning(),
                      title: "Technical Competitive Edge",
                      content:
                          "• Neural CLIP Embeddings: Semantic content matching that ignores cropping or filters.\n• Source Identification: Precise 'Patient Zero' tracing to identify internal or partner leaks.\n• Automated Enforcement: Rapid DMCA generation and platform-level alerting.",
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accentAmber.withAlpha(26),
                        border: Border.all(color: AppColors.accentAmber),
                      ),
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.info(),
                              color: AppColors.accentAmber, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Note: This app is currently in DEMO MODE. Live backend wiring to Firestore is toggled in core/config/demo_config.dart.",
                              style: AppTextStyles.body(
                                  size: 12,
                                  color: AppColors.accentAmber,
                                  weight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // FOOTER
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.borderDefault)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ScaleButton(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.accentBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Close Overview",
                        style: AppTextStyles.buttonLabel.copyWith(
                          color: Colors.white, 
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
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

class _GuideSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _GuideSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: c.accentBlue.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: c.accentBlue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.display(
                  size: 15,
                  weight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: AppTextStyles.body(
                  size: 14,
                  color: c.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
