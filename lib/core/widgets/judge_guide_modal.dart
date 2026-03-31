import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
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
    return Center(
      child: Container(
        width: 600,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.bookOpen(), color: AppColors.accentBlue, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    "JUDGE'S OPERATIONS MANUAL",
                    style: AppTextStyles.mono(size: 16, weight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 1),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(PhosphorIcons.x(), color: AppColors.textMuted),
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
                      title: "1. THE VALUE PROPOSITION",
                      content: "Sentinel AI protects high-value sports media using 'Dual-Lock' security. We combine C2PA cryptographic manifests with invisible AES-256 steganographic watermarks that survive re-compression and cropping.",
                    ),
                    const SizedBox(height: 24),
                    _GuideSection(
                      title: "2. DEMO FLOW: THE 'LEAK' STORY",
                      content: "Step A: Go to ASSET VAULT. Notice the 'C2PA Secured' badges.\nStep B: Go to THREAT RADAR. See real-time matches found by our CLIP-aligned neural engine.\nStep C: Open a threat. Compare the 'Vaulted Master' vs 'Unauthorized Copy'. Notice the Gemini AI reasoning for Piracy vs Fair Use.\nStep D: Go to CONTAGION MAP. Visualize how one leak on Telegram spread to X and YouTube.",
                    ),
                    const SizedBox(height: 24),
                    _GuideSection(
                      title: "3. TECHNICAL EDGE",
                      content: "• CLIP Embeddings: Semantic search that understands 'what is happening' in the video, not just pixels.\n• Patient Zero Tracing: Our watermarks identify EXACTLY who leaked the file (e.g. 'Sony LIV Partner' vs 'Internal Editor').\n• Automated Enforcement: Gemini AI drafts legally-compliant DMCA notices in seconds.",
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
                          Icon(PhosphorIcons.info(), color: AppColors.accentAmber, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Note: This app is currently in DEMO MODE. Live backend wiring to Firestore is toggled in core/config/demo_config.dart.",
                              style: AppTextStyles.mono(size: 10, color: AppColors.accentAmber, weight: FontWeight.w600),
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
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderDefault)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ScaleButton(
                    onTap: () => Navigator.pop(context),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      onPressed: () {}, // Handled by ScaleButton
                      child: Text("ACKNOWLEDGED", style: AppTextStyles.buttonLabel),
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
  final String title;
  final String content;

  const _GuideSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.mono(size: 12, weight: FontWeight.w700, color: AppColors.accentBlue, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: AppTextStyles.sans(size: 14, color: AppColors.textSecondary, height: 1.6),
        ),
      ],
    );
  }
}
