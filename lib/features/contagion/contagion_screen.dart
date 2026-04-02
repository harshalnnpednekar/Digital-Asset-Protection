import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/shimmer_box.dart';
import 'contagion_mock_data.dart';
import 'widgets/contagion_graph_painter.dart';
import 'widgets/node_detail_sidebar.dart';

class ContagionScreen extends StatefulWidget {
  const ContagionScreen({super.key});

  @override
  State<ContagionScreen> createState() => _ContagionScreenState();
}

class _ContagionScreenState extends State<ContagionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _selectedNodeId;
  bool _isLoading = true;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _simulateLoading();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerGraph();
    });
  }

  void _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _isLoading = false);
  }

  void _centerGraph() {
    const double zoom = 1.0;
    _transformationController.value = Matrix4.diagonal3Values(zoom, zoom, 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selectedNode = _selectedNodeId != null
        ? ContagionMockData.nodes.firstWhere((n) => n.id == _selectedNodeId)
        : null;

    final parentNode = selectedNode?.parentId != null
        ? ContagionMockData.nodes
            .firstWhere((n) => n.id == selectedNode!.parentId)
        : null;

    final childCount = _selectedNodeId != null
        ? ContagionMockData.nodes
            .where((n) => n.parentId == _selectedNodeId)
            .length
        : 0;

    return Scaffold(
      backgroundColor: c.bgPrimary,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            const SectionHeader(
              title: "Propagation Map",
              subtitle:
                  "Visualizing real-time node propagation and piracy leak distribution across platforms.",
            ),

            const SizedBox(height: 16),
            const _AssetSelectorBar(),
            const SizedBox(height: 16),

            // MAIN GRAPH AREA
            Expanded(
              child: Row(
                children: [
                  // GRAPH PANEL
                  Expanded(
                    flex: 7,
                    child: Container(
                      decoration: BoxDecoration(
                        color: c.bgPrimary,
                        border: Border.all(color: c.borderDefault),
                      ),
                      child: _isLoading
                          ? const ShimmerBox(
                              height: double.infinity, width: double.infinity)
                          : ClipRect(
                              child: InteractiveViewer(
                                transformationController:
                                    _transformationController,
                                minScale: 0.5,
                                maxScale: 3.0,
                                boundaryMargin: const EdgeInsets.all(500),
                                child: GestureDetector(
                                  onTapDown: (details) {
                                    final painter = ContagionGraphPainter(
                                      nodes: ContagionMockData.nodes,
                                      animationValue: _controller.value,
                                      colors: c,
                                    );
                                    // We need the local position relative to the graph canvas
                                    final offset = details.localPosition;
                                    final hitId = painter.findNodeAt(offset);
                                    setState(() => _selectedNodeId = hitId);
                                  },
                                  child: AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        size: const Size(1200, 800),
                                        painter: ContagionGraphPainter(
                                          nodes: ContagionMockData.nodes,
                                          selectedNodeId: _selectedNodeId,
                                          animationValue: _controller.value,
                                          colors: c,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // SIDEBAR
                  NodeDetailSidebar(
                    node: selectedNode,
                    parentNode: parentNode,
                    childCount: childCount,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const _ContagionSummaryBar(),
          ],
        ),
      ),
    );
  }
}

class _AssetSelectorBar extends StatelessWidget {
  const _AssetSelectorBar();

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
          Text("Monitoring Asset:",
              style: AppTextStyles.body(
                  size: 11, color: c.textMuted, weight: FontWeight.w600)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: c.borderDefault),
            ),
            child: Row(
              children: [
                Text(
                  "IPL 2025 — MI vs CSK Highlights",
                  style: AppTextStyles.display(
                      size: 12,
                      weight: FontWeight.w600,
                      color: c.textPrimary),
                ),
                const SizedBox(width: 8),
                Icon(PhosphorIcons.caretDown(),
                    size: 14, color: c.textMuted),
              ],
            ),
          ),
          const Spacer(),
          const _InlineStatLabel(value: "17", label: "Nodes Identified"),
          const SizedBox(width: 24),
          const _InlineStatLabel(value: "4", label: "Platforms Affected"),
          const SizedBox(width: 24),
          const _InlineStatLabel(value: "2.4M", label: "Total Reach"),
          const SizedBox(width: 24),
          const _InlineStatLabel(value: "2h 17m", label: "Detection Latency"),
        ],
      ),
    );
  }
}

class _InlineStatLabel extends StatelessWidget {
  final String value;
  final String label;

  const _InlineStatLabel({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value,
            style: AppTextStyles.display(
                size: 18,
                weight: FontWeight.w700,
                color: AppColors.accentAmber)),
        Text(label,
            style: AppTextStyles.body(
                size: 10, color: c.textMuted, weight: FontWeight.w500)),
      ],
    );
  }
}

class _ContagionSummaryBar extends StatelessWidget {
  const _ContagionSummaryBar();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: c.bgSecondary,
        border: Border.all(color: c.borderDefault),
      ),
      child: Row(
        children: [
          Text("Total Propagation Summary",
              style: AppTextStyles.display(
                  size: 13, color: c.textMuted, weight: FontWeight.w600)),
          const Spacer(),
          _SummaryItem(
              icon: PhosphorIcons.treeStructure(),
              value: "17 Nodes",
              label: "Propagation points",
              color: AppColors.accentAmber),
          const SizedBox(width: 40),
          _SummaryItem(
              icon: PhosphorIcons.globe(),
              value: "4 Platforms",
              label: "Channels detected",
              color: c.accentBlue),
          const SizedBox(width: 40),
          _SummaryItem(
              icon: PhosphorIcons.users(),
              value: "2.4M Reach",
              label: "Est. impressions",
              color: AppColors.accentCrimson),
          const SizedBox(width: 40),
          _SummaryItem(
              icon: PhosphorIcons.clock(),
              value: "2h 17m",
              label: "Detection speed",
              color: AppColors.accentGreen),
          const SizedBox(width: 40),
          _SummaryItem(
              icon: PhosphorIcons.fileText(),
              value: "6 DMCA",
              label: "Takedowns filed",
              color: AppColors.accentPurple),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: AppTextStyles.display(
                    size: 13, weight: FontWeight.w700, color: color)),
            Text(label,
                style: AppTextStyles.body(size: 10, color: c.textMuted, weight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
