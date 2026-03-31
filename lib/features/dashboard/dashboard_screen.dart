import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

import 'dashboard_widgets.dart';
import 'dashboard_kpi_section.dart';
import 'dashboard_timeline_section.dart';
import 'dashboard_platforms_section.dart';
import 'dashboard_table_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION 0 — SYSTEM STATUS BAR
            const DashboardStatusBar(),
            const SizedBox(height: 28),

            // SECTION 1 — KPI CARDS
            const DashboardKpiSection(),
            const SizedBox(height: 28),

            // SECTION 2 — TWO COLUMN LAYOUT
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT: Threat Timeline card
                const Expanded(
                  flex: 6,
                  child: DashboardTimelineSection(),
                ),
                const SizedBox(width: 16),
                // RIGHT: Platforms & Detections
                const Expanded(
                  flex: 4,
                  child: DashboardPlatformsSection(),
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
