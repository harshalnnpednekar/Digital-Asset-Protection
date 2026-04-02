import 'package:flutter/material.dart';
import '../../core/theme/app_theme_colors.dart';

import 'dashboard_widgets.dart';
import 'dashboard_kpi_section.dart';
import 'dashboard_timeline_section.dart';
import 'dashboard_platforms_section.dart';
import 'dashboard_table_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    
    return Scaffold(
      backgroundColor: c.bgPrimary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION 0 — SYSTEM STATUS BAR
            const DashboardStatusBar(),
            const SizedBox(height: 28),

            // SECTION 1 — KPI CARDS
            DashboardKpiSection(loading: _isLoading),
            const SizedBox(height: 28),

            // SECTION 2 — TWO COLUMN LAYOUT
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT: Threat Timeline card
                Expanded(
                  flex: 6,
                  child: DashboardTimelineSection(loading: _isLoading),
                ),
                const SizedBox(width: 16),
                // RIGHT: Platforms & Detections
                Expanded(
                  flex: 4,
                  child: DashboardPlatformsSection(loading: _isLoading),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // SECTION 3 — PATIENT ZERO TABLE
            const DashboardTableSection(),
          ],
        ),
      ),
    );
  }
}
