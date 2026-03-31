import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'dashboard_mock_data.dart';
import 'dashboard_widgets.dart';

class DashboardTableSection extends StatelessWidget {
  const DashboardTableSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "RECENT PATIENT ZERO IDENTIFICATIONS",
          style: AppTextStyles.sectionLabel,
        ),
        const SizedBox(height: 12),
        _TableHeader(),
        // TODO: REPLACE WITH FIRESTORE STREAM
        ...DashboardMockData.patientZeroRecords.map(
          (record) => _TableRow(record: record),
        ).toList(),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "ASSET NAME",
              style: AppTextStyles.mono(size: 10, color: AppColors.textMuted, letterSpacing: 2.5),
            ),
          ),
          SizedBox(
            width: 180,
            child: Text(
              "LEAK SOURCE",
              style: AppTextStyles.mono(size: 10, color: AppColors.textMuted, letterSpacing: 2.5),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              "PLATFORM",
              style: AppTextStyles.mono(size: 10, color: AppColors.textMuted, letterSpacing: 2.5),
            ),
          ),
          SizedBox(
            width: 160,
            child: Text(
              "TIMESTAMP",
              style: AppTextStyles.mono(size: 10, color: AppColors.textMuted, letterSpacing: 2.5),
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(
              "STATUS",
              style: AppTextStyles.mono(size: 10, color: AppColors.textMuted, letterSpacing: 2.5),
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
    Color statusChipColor;
    switch (widget.record.status) {
      case "DMCA FILED":
        statusChipColor = AppColors.accentBlue;
        break;
      case "INVESTIGATING":
        statusChipColor = AppColors.accentAmber;
        break;
      case "RESOLVED":
        statusChipColor = AppColors.accentGreen;
        break;
      default:
        statusChipColor = AppColors.textMuted;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.bgOverlay : Colors.transparent,
          border: Border(
            bottom: const BorderSide(color: AppColors.borderDefault, width: 1),
            // The left accent on hover
            left: BorderSide(
              color: _isHovered ? AppColors.accentAmber : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.record.assetName,
                style: AppTextStyles.sans(size: 13, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 180,
              child: Text(
                widget.record.leakSource,
                style: AppTextStyles.mono(size: 12, color: AppColors.accentAmber),
              ),
            ),
            SizedBox(
              width: 120,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderDefault, width: 1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    widget.record.platform.toUpperCase(),
                    style: AppTextStyles.mono(size: 9, color: AppColors.textMuted, letterSpacing: 1),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 160,
              child: Text(
                widget.record.timestamp,
                style: AppTextStyles.mono(size: 11, color: AppColors.textMuted),
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
