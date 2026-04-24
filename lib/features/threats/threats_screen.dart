import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_dot.dart';
import '../../core/widgets/scale_button.dart';
import 'threats_mock_data.dart';
import 'widgets/threat_queue_item.dart';
import 'widgets/threat_detail_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class ThreatsScreen extends StatefulWidget {
  const ThreatsScreen({super.key});

  @override
  State<ThreatsScreen> createState() => _ThreatsScreenState();
}

class _ThreatsScreenState extends State<ThreatsScreen> {
  List<ThreatAlert> _alerts = [];
  final Set<String> _liveThreatIds = <String>{};
  String? _selectedThreatId;

  @override
  void initState() {
    super.initState();
  }

  void _updateStatus(String status) {
    if (_selectedThreatId == null ||
        !_liveThreatIds.contains(_selectedThreatId)) {
      return;
    }
    FirebaseFirestore.instance
        .collection('threat_alerts')
        .doc(_selectedThreatId)
        .update({'status': status}).catchError(
            (e) => debugPrint("Update failed: \$e"));
  }

  String _formatDetectedAt(Timestamp? detectedAt) {
    if (detectedAt == null) {
      return 'Live just now';
    }
    return DateFormat('hh:mm a').format(detectedAt.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final stream = FirebaseFirestore.instance
        .collection('threat_alerts')
        .orderBy('detected_at', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: c.bgPrimary,
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? const [];
          final liveAlerts = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ThreatAlert(
              threatId: doc.id,
              matchedAssetName:
                  (data['matched_asset_name'] as String?) ?? 'Unknown Asset',
              platform: (data['platform'] as String?) ?? 'Unknown',
              visualSimilarity:
                  (data['visual_similarity'] as num?)?.toDouble() ?? 0.0,
              audioSimilarity:
                  (data['audio_similarity'] as num?)?.toDouble() ?? 0.0,
              scrapedCaption:
                  (data['caption'] as String?) ?? 'No caption available',
              geminiIntent: ((data['gemini_intent'] as String?) ?? 'REVIEWING')
                  .toUpperCase(),
              geminiConfidence:
                  (data['gemini_confidence'] as num?)?.toDouble() ?? 0.0,
              geminiReasoning: (data['gemini_reasoning'] as String?) ??
                  'Pending analysis from Gemini.',
              detectionTime:
                  _formatDetectedAt(data['detected_at'] as Timestamp?),
              status: (data['status'] as String?) ?? 'ACTIVE',
              distributionTarget: (data['distribution_target'] as String?) ??
                  'Unknown Distribution',
              decryptedLeakSource:
                  (data['patient_zero'] as String?) ?? 'Partner: Unknown',
              patientZeroTimestamp: 'Recently',
              isLive: true,
            );
          }).toList();

          _liveThreatIds
            ..clear()
            ..addAll(liveAlerts.map((alert) => alert.threatId));

          _alerts = [...liveAlerts, ...ThreatsMockData.alerts];

          if (_selectedThreatId == null && _alerts.isNotEmpty ||
              (!_alerts.any((a) => a.threatId == _selectedThreatId) &&
                  _alerts.isNotEmpty)) {
            _selectedThreatId = _alerts.first.threatId;
          } else if (_alerts.isEmpty) {
            _selectedThreatId = null;
          }

          final activeCount = _alerts.where((a) => a.status == 'ACTIVE').length;
          final reviewingCount = _alerts
              .where(
                  (a) => a.geminiIntent == 'REVIEWING' && a.status == 'ACTIVE')
              .length;
          final dismissedCount =
              _alerts.where((a) => a.status == 'DISMISSED').length;

          final selectedThreat = _selectedThreatId != null
              ? _alerts.firstWhere((a) => a.threatId == _selectedThreatId,
                  orElse: () => _alerts.first)
              : null;

          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                SectionHeader(
                  title: "THREAT RADAR",
                  subtitle:
                      "Live neural monitoring of global media distribution — CLIP-aligned piracy detection",
                  trailing: Row(
                    children: [
                      _StatusCountChip(
                          label: "$activeCount ACTIVE",
                          color: AppColors.accentCrimson),
                      const SizedBox(width: 8),
                      _StatusCountChip(
                          label: "$reviewingCount REVIEWING",
                          color: AppColors.accentAmber),
                      const SizedBox(width: 8),
                      _StatusCountChip(
                          label: "$dismissedCount DISMISSED",
                          color: AppColors.accentGreen),
                      const SizedBox(width: 16),
                      ScaleButton(
                        onTap: () {},
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: c.accentBlue),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                          onPressed: () {},
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.broadcast(),
                                  size: 14, color: c.accentBlue),
                              const SizedBox(width: 6),
                              Text(
                                "SCAN NOW",
                                style: AppTextStyles.mono(
                                    size: 11,
                                    weight: FontWeight.w700,
                                    color: c.accentBlue,
                                    letterSpacing: 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                // MAIN PANELS
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT PANEL: QUEUE
                      Expanded(
                        flex: 35,
                        child: Container(
                          decoration: BoxDecoration(
                            color: c.bgSecondary,
                            border: Border.all(color: c.borderDefault),
                          ),
                          child: Column(
                            children: [
                              _PanelHeader(
                                title: "THREAT QUEUE",
                                trailing: Text("${_alerts.length} ITEMS",
                                    style: AppTextStyles.mono(
                                        size: 10, color: c.textMuted)),
                              ),
                              Expanded(
                                child: _alerts.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(PhosphorIcons.shieldCheck(),
                                                size: 40,
                                                color:
                                                    c.textMuted.withAlpha(51)),
                                            const SizedBox(height: 12),
                                            Text(
                                              "NO ACTIVE THREATS",
                                              style: AppTextStyles.mono(
                                                  size: 12,
                                                  weight: FontWeight.w600,
                                                  color: c.textMuted),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting)
                                            const Padding(
                                              padding: EdgeInsets.only(top: 8),
                                              child: SizedBox(
                                                height: 16,
                                                width: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              ),
                                            ),
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: _alerts.length,
                                              itemBuilder: (context, index) {
                                                final threat = _alerts[index];
                                                return ThreatQueueItem(
                                                  threat: threat,
                                                  isSelected:
                                                      _selectedThreatId ==
                                                          threat.threatId,
                                                  onTap: () {
                                                    setState(() => _selectedThreatId = threat.threatId);
                                                    context.push('/contagion?threatId=${threat.threatId}');
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // RIGHT PANEL: DEEP-DIVE
                      Expanded(
                        flex: 65,
                        child: Container(
                          decoration: BoxDecoration(
                            color: c.bgSecondary,
                            border: Border.all(color: c.borderDefault),
                          ),
                          child: selectedThreat == null
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(PhosphorIcons.broadcast(),
                                          size: 64,
                                          color: c.textMuted.withAlpha(77)),
                                      const SizedBox(height: 16),
                                      Text(
                                        "SELECT A THREAT FROM THE QUEUE",
                                        style: AppTextStyles.mono(
                                            size: 14,
                                            color: c.textMuted,
                                            letterSpacing: 1),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Click any threat item to view full evidence and AI analysis",
                                        style: AppTextStyles.mono(
                                            size: 11, color: c.textMuted),
                                      ),
                                    ],
                                  ),
                                )
                              : ThreatDetailPanel(
                                  key: ValueKey(selectedThreat.threatId),
                                  threat: selectedThreat,
                                  onUpdateStatus: _updateStatus,
                                )
                                  .animate(
                                      key: ValueKey(selectedThreat.threatId))
                                  .fadeIn(duration: 300.ms)
                                  .slideX(
                                      begin: 0.02,
                                      end: 0,
                                      curve: Curves.easeOutCubic),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusCountChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusCountChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusDot(color: color, size: 6),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.mono(
                size: 11,
                weight: FontWeight.w700,
                color: color,
                letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final String title;
  final Widget trailing;

  const _PanelHeader({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.borderDefault)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.mono(
              size: 11,
              weight: FontWeight.w600,
              color: c.textMuted,
              letterSpacing: 2.5,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}
