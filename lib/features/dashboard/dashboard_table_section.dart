import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
          "SOURCE IDENTIFICATION",
          style: AppTextStyles.mono(
            size: 13, 
            weight: FontWeight.w700, 
            color: c.textMuted,
            letterSpacing: 1.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      decoration: BoxDecoration(
        color: c.bgSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border.all(color: c.borderDefault),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "PROTECTED ASSET",
              style: AppTextStyles.display(
                  size: 11, color: c.textMuted, weight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              "IDENTIFIED SOURCE",
              style: AppTextStyles.display(
                  size: 11, color: c.textMuted, weight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
          Expanded(
            flex: 5, // Ample space for Vector chips
            child: Text(
              "VECTOR",
              style: AppTextStyles.display(
                  size: 11, color: c.textMuted, weight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
          Expanded(
            flex: 5, // Ample space for Time
            child: Text(
              "DETECTION TIME",
              style: AppTextStyles.display(
                  size: 11, color: c.textMuted, weight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              "STATUS",
              style: AppTextStyles.display(
                  size: 11, color: c.textMuted, weight: FontWeight.w800, letterSpacing: 1),
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

    final isPartner = widget.record.leakSource.toLowerCase().contains("partner");

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: _isHovered ? c.bgTertiary : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: c.borderDefault, width: 1),
            left: BorderSide(color: c.borderDefault, width: 1),
            right: BorderSide(color: c.borderDefault, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                   Icon(PhosphorIcons.monitor(), size: 16, color: c.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.record.assetName,
                      style: AppTextStyles.body(size: 14, weight: FontWeight.w600, color: c.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Icon(
                    isPartner ? PhosphorIcons.link() : PhosphorIcons.user(),
                    size: 14,
                    color: isPartner ? c.accentBlue : AppColors.accentAmber,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.record.leakSource,
                    style: AppTextStyles.mono(
                      size: 12,
                      weight: FontWeight.w600, 
                      color: isPartner ? c.textPrimary : AppColors.accentAmber
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5, // Match Header
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.bgPrimary,
                      border: Border.all(color: c.borderDefault, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.record.platform.toUpperCase(),
                      style: AppTextStyles.display(
                          size: 9, color: c.textMuted, weight: FontWeight.w800, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5, // Match Header
              child: Text(
                widget.record.timestamp,
                style: AppTextStyles.mono(size: 11, color: c.textMuted, weight: FontWeight.w500),
              ),
            ),
            SizedBox(
              width: 120,
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
