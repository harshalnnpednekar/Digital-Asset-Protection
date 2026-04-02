import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/config/demo_config.dart';
import 'dashboard_mock_data.dart';
import 'dashboard_widgets.dart';

class DashboardTableSection extends StatelessWidget {
  const DashboardTableSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Source Identification",
          style: AppTextStyles.display(
            size: 16, 
            weight: FontWeight.w700, 
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        const _TableHeader(),
        if (kDemoMode)
          ...DashboardMockData.patientZeroRecords.map(
            (record) => _TableRow(record: record),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: c.borderDefault),
                left: BorderSide(color: c.borderDefault),
                right: BorderSide(color: c.borderDefault),
              ),
            ),
            child: Center(
              child: Text(
                "NO RECENT IDENTIFICATIONS FOUND",
                style: AppTextStyles.mono(
                  size: 12, 
                  color: c.textMuted, 
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: c.bgSecondary,
        border: Border.all(color: c.borderDefault),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Asset Name",
              style: AppTextStyles.display(
                  size: 11, color: c.textMuted, weight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 180,
            child: Text(
              "Leak Source",
              style: AppTextStyles.display(
                  size: 11, color: c.textMuted, weight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              "Platform",
              style: AppTextStyles.display(
                  size: 11, color: c.textMuted, weight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 160,
            child: Text(
              "Timestamp",
              style: AppTextStyles.display(
                  size: 11, color: c.textMuted, weight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(
              "Status",
              style: AppTextStyles.display(
                  size: 11, color: c.textMuted, weight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatefulWidget {
  final PatientZeroRecord record;

  const _TableRow({required this.record});

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Color statusChipColor;
    switch (widget.record.status) {
      case "DMCA FILED":
        statusChipColor = c.accentBlue;
        break;
      case "INVESTIGATING":
        statusChipColor = AppColors.accentAmber;
        break;
      case "RESOLVED":
        statusChipColor = AppColors.accentGreen;
        break;
      default:
        statusChipColor = c.textMuted;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _isHovered ? c.bgOverlay : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: c.borderDefault, width: 1),
            // The left accent on hover
            left: BorderSide(
              color: _isHovered ? AppColors.accentAmber : Colors.transparent,
              width: 3,
            ),
            right: BorderSide(color: c.borderDefault, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.record.assetName,
                style:
                    AppTextStyles.body(size: 14, weight: FontWeight.w600, color: c.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 180,
              child: Text(
                widget.record.leakSource,
                style:
                    AppTextStyles.body(size: 13, weight: FontWeight.w700, color: AppColors.accentAmber),
              ),
            ),
            SizedBox(
              width: 120,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: c.borderDefault, width: 1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    widget.record.platform.toUpperCase(),
                    style: AppTextStyles.display(
                        size: 10, color: c.textMuted, weight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 160,
              child: Text(
                widget.record.timestamp,
                style: AppTextStyles.body(size: 12, color: c.textMuted, weight: FontWeight.w500),
              ),
            ),
            SizedBox(
              width: 140,
              child: CustomChip(
                label: widget.record.status,
                color: statusChipColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
