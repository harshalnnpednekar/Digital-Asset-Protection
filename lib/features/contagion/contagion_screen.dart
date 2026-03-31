import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/section_header.dart';
import 'contagion_mock_data.dart';
import 'widgets/contagion_graph_painter.dart';
import 'widgets/node_detail_sidebar.dart';

class ContagionScreen extends StatefulWidget {
  const ContagionScreen({super.key});

  @override
  State<ContagionScreen> createState() => _ContagionScreenState();
}

class _ContagionScreenState extends State<ContagionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _selectedNodeId;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    
    // Initial centering of the graph
    // The graph is approx 1000px wide based on the painter logic
    // We'll center it after the layout is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerGraph();
    });
  }

  void _centerGraph() {
    // A simple heuristic for centering on a 1200x800 canvas
    final double zoom = 1.0;
    _transformationController.value = Matrix4.identity()..scale(zoom);
  }

  @override
  void dispose() {
    _controller.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedNode = _selectedNodeId != null 
        ? ContagionMockData.nodes.firstWhere((n) => n.id == _selectedNodeId) 
        : null;
    
    final parentNode = selectedNode?.parentId != null 
        ? ContagionMockData.nodes.firstWhere((n) => n.id == selectedNode!.parentId) 
        : null;

    final childCount = _selectedNodeId != null 
        ? ContagionMockData.nodes.where((n) => n.parentId == _selectedNodeId).length 
        : 0;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            const SectionHeader(
              title: "CONTAGION MAP",
              subtitle: "Live node-graph visualization of piracy propagation topology — Real-time leak tracing",
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
                        color: AppColors.bgPrimary,
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: ClipRect(
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          minScale: 0.5,
                          maxScale: 3.0,
                          boundaryMargin: const EdgeInsets.all(500),
                          child: GestureDetector(
                            onTapDown: (details) {
                              final painter = ContagionGraphPainter(
                                nodes: ContagionMockData.nodes,
                                animationValue: _controller.value,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Text("TRACKING ASSET:", style: AppTextStyles.mono(size: 11, color: AppColors.textMuted, letterSpacing: 2)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Row(
              children: [
                Text(
                  "IPL 2025 — MI vs CSK Highlights",
                  style: AppTextStyles.mono(size: 11, weight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 8),
                Icon(PhosphorIcons.caretDown(), size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
          const Spacer(),
          _InlineStatLabel(value: "17", label: "NODES IDENTIFIED"),
          const SizedBox(width: 24),
          _InlineStatLabel(value: "4", label: "PLATFORMS AFFECTED"),
          const SizedBox(width: 24),
          _InlineStatLabel(value: "2.4M", label: "TOTAL REACH"),
          const SizedBox(width: 24),
          _InlineStatLabel(value: "2h 17m", label: "TIME TO DETECT"),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value, style: AppTextStyles.mono(size: 16, weight: FontWeight.w700, color: AppColors.accentAmber)),
        Text(label, style: AppTextStyles.mono(size: 9, color: AppColors.textMuted, letterSpacing: 2)),
      ],
    );
  }
}

class _ContagionSummaryBar extends StatelessWidget {
  const _ContagionSummaryBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Text("TOTAL PROPAGATION SUMMARY", style: AppTextStyles.mono(size: 10, color: AppColors.textMuted, letterSpacing: 2.5)),
          const Spacer(),
          _SummaryItem(icon: PhosphorIcons.treeStructure(), value: "17 NODES", label: "Propagation points", color: AppColors.accentAmber),
          const SizedBox(width: 40),
          _SummaryItem(icon: PhosphorIcons.globe(), value: "4 PLATFORMS", label: "Channels detected", color: AppColors.accentBlue),
          const SizedBox(width: 40),
          _SummaryItem(icon: PhosphorIcons.users(), value: "2.4M REACH", label: "Est. impressions", color: AppColors.accentCrimson),
          const SizedBox(width: 40),
          _SummaryItem(icon: PhosphorIcons.clock(), value: "2H 17M", label: "Detection speed", color: AppColors.accentGreen),
          const SizedBox(width: 40),
          _SummaryItem(icon: PhosphorIcons.fileText(), value: "6 DMCA", label: "Takedowns filed", color: AppColors.accentPurple),
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
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTextStyles.mono(size: 12, weight: FontWeight.w700, color: color)),
            Text(label, style: AppTextStyles.mono(size: 9, color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }
}
