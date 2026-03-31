import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_dot.dart';
import 'threats_mock_data.dart';
import 'widgets/threat_queue_item.dart';
import 'widgets/threat_detail_panel.dart';

class ThreatsScreen extends StatefulWidget {
  const ThreatsScreen({super.key});

  @override
  State<ThreatsScreen> createState() => _ThreatsScreenState();
}

class _ThreatsScreenState extends State<ThreatsScreen> {
  late List<ThreatAlert> _alerts;
  String? _selectedThreatId;

  @override
  void initState() {
    super.initState();
    _alerts = List.from(ThreatsMockData.alerts);
    if (_alerts.isNotEmpty) {
      _selectedThreatId = _alerts.first.threatId;
    }
  }

  void _updateStatus(String status) {
    if (_selectedThreatId == null) return;
    setState(() {
      final index = _alerts.indexWhere((a) => a.threatId == _selectedThreatId);
      if (index != -1) {
        _alerts[index] = _alerts[index].copyWith(status: status);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _alerts.where((a) => a.status == 'ACTIVE').length;
    final reviewingCount = _alerts.where((a) => a.geminiIntent == 'REVIEWING' && a.status == 'ACTIVE').length;
    final dismissedCount = _alerts.where((a) => a.status == 'DISMISSED').length;

    final selectedThreat = _selectedThreatId != null 
        ? _alerts.firstWhere((a) => a.threatId == _selectedThreatId) 
        : null;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            SectionHeader(
              title: "THREAT RADAR",
              subtitle: "Live neural monitoring of global media distribution — CLIP-aligned piracy detection",
              trailing: Row(
                children: [
                  _StatusCountChip(label: "$activeCount ACTIVE", color: AppColors.accentCrimson),
                  const SizedBox(width: 8),
                  _StatusCountChip(label: "$reviewingCount REVIEWING", color: AppColors.accentAmber),
                  const SizedBox(width: 8),
                  _StatusCountChip(label: "$dismissedCount DISMISSED", color: AppColors.accentGreen),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.accentBlue),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: () {},
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.broadcast(), size: 14, color: AppColors.accentBlue),
                        const SizedBox(width: 6),
                        Text(
                          "SCAN NOW",
                          style: AppTextStyles.mono(size: 11, weight: FontWeight.w700, color: AppColors.accentBlue, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const _ThreatStatusBar(),
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
                        color: AppColors.bgSecondary,
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: Column(
                        children: [
                          _PanelHeader(
                            title: "THREAT QUEUE",
                            trailing: Text("${_alerts.length} ITEMS", style: AppTextStyles.mono(size: 10, color: AppColors.textMuted)),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _alerts.length,
                              itemBuilder: (context, index) {
                                final threat = _alerts[index];
                                return ThreatQueueItem(
                                  threat: threat,
                                  isSelected: _selectedThreatId == threat.threatId,
                                  onTap: () => setState(() => _selectedThreatId = threat.threatId),
                                );
                              },
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
                        color: AppColors.bgSecondary,
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: selectedThreat == null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(PhosphorIcons.broadcast(), size: 64, color: AppColors.textMuted.withAlpha(77)),
                                  const SizedBox(height: 16),
                                  Text(
                                    "SELECT A THREAT FROM THE QUEUE",
                                    style: AppTextStyles.mono(size: 14, color: AppColors.textMuted, letterSpacing: 1),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Click any threat item to view full evidence and AI analysis",
                                    style: AppTextStyles.sans(size: 13, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            )
                          : ThreatDetailPanel(
                              key: ValueKey(selectedThreat.threatId),
                              threat: selectedThreat,
                              onUpdateStatus: _updateStatus,
                            ).animate(key: ValueKey(selectedThreat.threatId))
                              .fadeIn(duration: 300.ms)
                              .slideX(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
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
            style: AppTextStyles.mono(size: 11, weight: FontWeight.w700, color: color, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _ThreatStatusBar extends StatelessWidget {
  const _ThreatStatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Text("THREAT INTELLIGENCE FEED", style: AppTextStyles.sectionLabel),
          const Spacer(),
          Row(
            children: [
              const StatusDot(color: AppColors.accentGreen, size: 6),
              const SizedBox(width: 6),
              Text(
                "LIVE — Last scan completed 14 seconds ago",
                style: AppTextStyles.mono(size: 10, color: AppColors.accentGreen, letterSpacing: 0.5),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "SCAN INTERVAL: 30s  //  THRESHOLD: 85%  //  ENGINE: CLIP + GEMINI 1.5",
            style: AppTextStyles.mono(size: 10, color: AppColors.textMuted, letterSpacing: 0.5),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.sectionLabel),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}
