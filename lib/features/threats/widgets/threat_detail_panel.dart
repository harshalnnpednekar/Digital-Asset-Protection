import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_chip.dart';
import '../threats_mock_data.dart';
import 'confidence_circle.dart';

class ThreatDetailPanel extends StatelessWidget {
  final ThreatAlert threat;
  final Function(String) onUpdateStatus;

  const ThreatDetailPanel({
    super.key,
    required this.threat,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    Color intentColor;
    switch (threat.geminiIntent) {
      case 'PIRACY':
        intentColor = AppColors.accentCrimson;
        break;
      case 'REVIEWING':
        intentColor = AppColors.accentAmber;
        break;
      case 'FAIR_USE':
        intentColor = AppColors.accentGreen;
        break;
      default:
        intentColor = AppColors.textMuted;
    }

    // Override for filed DMCA
    if (threat.status == 'DMCA_FILED') {
      intentColor = AppColors.accentBlue;
    } else if (threat.status == 'DISMISSED') {
      intentColor = AppColors.accentGreen;
    }

    final intentBgColor = intentColor.withAlpha(26); // approx 10% opacity

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A: PANEL HEADER
          _SectionWrapper(
            borderBottom: true,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      threat.matchedAssetName,
                      style: AppTextStyles.mono(size: 14, weight: FontWeight.w700, color: AppColors.textPrimary),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _PlatformBadge(platform: threat.platform),
                        const SizedBox(width: 8),
                        Text(
                          "DETECTED: ${threat.detectionTime.toUpperCase()}",
                          style: AppTextStyles.mono(size: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                CustomChip(label: threat.geminiIntent, color: intentColor),
              ],
            ),
          ),

          // B: EVIDENCE COMPARISON
          _SectionHeader(label: "EVIDENCE COMPARISON"),
          _SectionWrapper(
            child: Row(
              children: [
                Expanded(
                  child: _EvidenceStack(
                    isOriginal: true,
                    label: "ORIGINAL // VAULTED MASTER",
                    assetName: threat.matchedAssetName,
                    chipLabel: "VAULTED",
                    chipColor: AppColors.accentGreen,
                    icon: PhosphorIcons.videoCamera(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _EvidenceStack(
                    isOriginal: false,
                    label: "FLAGGED // SCRAPED CONTENT",
                    assetName: threat.scrapedCaption,
                    chipLabel: "⚠ UNAUTHORIZED",
                    chipColor: AppColors.accentCrimson,
                    icon: PhosphorIcons.prohibit(),
                    platformBadge: _PlatformBadge(platform: threat.platform),
                  ),
                ),
              ],
            ),
          ),
          
          Center(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.accentBlue),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {},
              child: Text(
                "▶  PLAY BOTH SIMULTANEOUSLY",
                style: AppTextStyles.mono(size: 11, weight: FontWeight.w700, color: AppColors.accentBlue, letterSpacing: 1),
              ),
            ),
          ),
          
          const SizedBox(height: 24),

          // C: CONFIDENCE SCORES
          _SectionHeader(label: "MATCH CONFIDENCE ANALYSIS"),
          _SectionWrapper(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ConfidenceCircle(label: "VISUAL SIMILARITY", value: threat.visualSimilarity),
                    ConfidenceCircle(label: "AUDIO WAVEFORM MATCH", value: threat.audioSimilarity),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "DUAL-LOCK CONFIRMATION: Both visual semantic embeddings AND audio waveform vectors exceed the 85% detection threshold.",
                  style: AppTextStyles.sans(size: 11, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // D: GEMINI AI VERDICT
          _SectionWrapper(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: intentBgColor,
                border: Border(left: BorderSide(color: intentColor, width: 4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("GEMINI AI INTENT ANALYSIS", style: AppTextStyles.mono(size: 10, color: AppColors.textMuted, letterSpacing: 2)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                threat.geminiIntent == 'PIRACY' ? PhosphorIcons.warningCircle() : PhosphorIcons.checkCircle(),
                                size: 18,
                                color: intentColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                threat.geminiIntent == 'PIRACY' ? "PIRACY DETECTED" : "FAIR USE DETECTED",
                                style: AppTextStyles.mono(size: 16, weight: FontWeight.w700, color: intentColor, letterSpacing: 1),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("CONFIDENCE", style: AppTextStyles.mono(size: 9, color: AppColors.textMuted, letterSpacing: 1)),
                          Text(
                            "${(threat.geminiConfidence * 100).toStringAsFixed(1)}%",
                            style: AppTextStyles.mono(size: 20, weight: FontWeight.w700, color: intentColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: intentColor.withAlpha(77)),
                  const SizedBox(height: 12),
                  Text(
                    '"${threat.geminiReasoning}"',
                    style: AppTextStyles.sans(
                      size: 12,
                      color: AppColors.textSecondary,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // E: PATIENT ZERO
          _SectionWrapper(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentCrimsonDim,
                border: Border.all(color: AppColors.accentCrimson, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(PhosphorIcons.dna(), size: 16, color: AppColors.accentCrimson),
                          const SizedBox(width: 8),
                          Text(
                            "PATIENT ZERO IDENTIFIED",
                            style: AppTextStyles.mono(size: 13, weight: FontWeight.w700, color: AppColors.accentCrimson, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      const CustomChip(label: "DECRYPTED", color: AppColors.accentCrimson),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DataRow(label: "LEAK SOURCE", value: threat.decryptedLeakSource, valueColor: AppColors.accentAmber),
                  _DataRow(
                    label: "DISTRIBUTION MARKER", 
                    value: "[AES-256 Payload: ${threat.threatId.hashCode.toRadixString(16).toUpperCase()}]", 
                    valueColor: AppColors.textSecondary
                  ),
                  _DataRow(label: "MARKER ASSIGNED ON", value: threat.patientZeroTimestamp, valueColor: AppColors.textSecondary),
                  _DataRow(label: "BREACH TYPE", value: "Unauthorized External Distribution", valueColor: AppColors.textSecondary),
                  _DataRow(label: "FIRST DETECTED", value: threat.detectionTime, valueColor: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    "Steganographic payload decrypted from media bitstream — admissible as digital forensic evidence",
                    style: AppTextStyles.mono(size: 9, color: AppColors.textMuted, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ),

          // F: ACTION BUTTONS
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderDefault)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderDefault),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => onUpdateStatus('DISMISSED'),
                    child: Text(
                      "DISMISS AS FAIR USE",
                      style: AppTextStyles.mono(size: 12, weight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentAmber,
                      foregroundColor: AppColors.textOnAmber,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _showDMCAConfirmation(context),
                    child: Text(
                      "GENERATE & SUBMIT DMCA  →",
                      style: AppTextStyles.buttonLabel,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showDMCAConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(204),
      builder: (context) => Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "CONFIRM DMCA ENFORCEMENT",
                style: AppTextStyles.mono(size: 14, weight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                "An automated DMCA takedown notice will be drafted by Gemini AI and submitted to ${threat.platform}. This action is logged and irreversible.",
                style: AppTextStyles.sans(size: 13, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderDefault),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: const Text("CANCEL"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onUpdateStatus('DMCA_FILED');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentCrimson,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: const Text("CONFIRM & FILE"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(label, style: AppTextStyles.sectionLabel),
    );
  }
}

class _SectionWrapper extends StatelessWidget {
  final Widget child;
  final bool borderBottom;
  const _SectionWrapper({required this.child, this.borderBottom = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: borderBottom ? const Border(bottom: BorderSide(color: AppColors.borderDefault)) : null,
      ),
      child: child,
    );
  }
}

class _EvidenceStack extends StatelessWidget {
  final bool isOriginal;
  final String label;
  final String assetName;
  final String chipLabel;
  final Color chipColor;
  final IconData icon;
  final Widget? platformBadge;

  const _EvidenceStack({
    required this.isOriginal,
    required this.label,
    required this.assetName,
    required this.chipLabel,
    required this.chipColor,
    required this.icon,
    this.platformBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 2,
          color: chipColor,
        ),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: isOriginal ? AppColors.bgTertiary : AppColors.accentCrimsonDim,
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 32, color: isOriginal ? AppColors.textMuted : AppColors.accentCrimson.withAlpha(153)),
                      const SizedBox(height: 8),
                      Text(
                        isOriginal ? "ORIGINAL ASSET" : "UNAUTHORIZED COPY",
                        style: AppTextStyles.mono(size: 9, color: isOriginal ? AppColors.textMuted : AppColors.accentCrimson, letterSpacing: 2),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: CustomChip(label: chipLabel, color: chipColor),
                ),
                if (platformBadge != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: platformBadge!,
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.mono(size: 9, color: AppColors.textMuted, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(
                assetName,
                style: AppTextStyles.sans(size: 11, weight: FontWeight.w500, color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _DataRow({required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: AppTextStyles.mono(size: 10, color: AppColors.textMuted, letterSpacing: 2)),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.sans(size: 12, weight: FontWeight.w500, color: valueColor),
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
