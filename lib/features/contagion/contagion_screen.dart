import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_colors.dart';
import 'contagion_mock_data.dart';
import 'widgets/contagion_graph_painter.dart'; // This file was renamed class-wise to PropagationFlowPainter
import 'widgets/node_detail_sidebar.dart';

class PropagationFlowScreen extends StatefulWidget {
  const PropagationFlowScreen({super.key});

  @override
  State<PropagationFlowScreen> createState() => _PropagationFlowScreenState();
}

class _PropagationFlowScreenState extends State<PropagationFlowScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _selectedNodeId;
  bool _isLoading = true;

  // Tracking node positions for tap detection
  Map<String, Offset> _nodePositions = {};

  // Asset Selection State
  String _selectedAsset = "IPL 2025 — MI vs CSK Highlights";
  final List<String> _assets = [
    "IPL 2025 — MI vs CSK Highlights",
    "ICC Champions Trophy — IND vs PAK",
    "Premier League — LIV vs MCI",
    "Wimbledon 2025 — Semi-Finals",
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _simulateLoading();
  }

  void _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    // Derived Data
    const activeNodes =
        ContagionMockData.nodes; // In real app, filter by _selectedAsset
    final selectedNode = _selectedNodeId != null
        ? activeNodes.firstWhere((n) => n.id == _selectedNodeId)
        : null;

    final parentNode = selectedNode?.parentId != null
        ? activeNodes.firstWhere((n) => n.id == selectedNode!.parentId)
        : null;

    final childCount = _selectedNodeId != null
        ? activeNodes.where((n) => n.parentId == _selectedNodeId).length
        : 0;

    return Scaffold(
      backgroundColor: c.bgPrimary,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // COMPACT HEADER
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PROPAGATION FLOW",
                        style: AppTextStyles.display(
                          size: 18,
                          weight: FontWeight.w800,
                          color: c.textPrimary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Corporate forensic trace of unauthorized media distribution.",
                        style: AppTextStyles.body(size: 12, color: c.textMuted),
                      ),
                    ],
                  ),
                ),
                // Inline legend
                Row(
                  children: [
                    _dot(AppColors.accentCrimson),
                    const SizedBox(width: 8),
                    Text("Origin",
                        style: AppTextStyles.mono(
                            size: 10,
                            color: c.textMuted,
                            weight: FontWeight.w700)),
                    const SizedBox(width: 20),
                    _dot(AppColors.accentAmber),
                    const SizedBox(width: 8),
                    Text("Vector",
                        style: AppTextStyles.mono(
                            size: 10,
                            color: c.textMuted,
                            weight: FontWeight.w700)),
                    const SizedBox(width: 20),
                    _dot(c.accentBlue),
                    const SizedBox(width: 8),
                    Text("Target",
                        style: AppTextStyles.mono(
                            size: 10,
                            color: c.textMuted,
                            weight: FontWeight.w700)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            _buildAssetSelectorBar(c),
            const SizedBox(height: 12),

            // THE GRAPH
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: c.bgSecondary,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: c.borderDefault),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: _buildGraphView(context, c, activeNodes),
                    ),
                  ),

                  // SIDEBAR
                  if (_selectedNodeId != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      child: NodeDetailSidebar(
                        node: selectedNode,
                        parentNode: parentNode,
                        childCount: childCount,
                        onClose: () => setState(() => _selectedNodeId = null),
                      ).animate().slideX(
                          begin: 1,
                          end: 0,
                          duration: 250.ms,
                          curve: Curves.easeOutCubic),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetSelectorBar(AppThemeColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: c.bgSecondary,
        border: Border.all(color: c.borderDefault),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.broadcast(), size: 16, color: c.textMuted),
          const SizedBox(width: 12),
          Text("MONITORING:",
              style: AppTextStyles.mono(
                  size: 10,
                  color: c.textMuted,
                  weight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedAsset = value;
                _selectedNodeId = null;
              });
              _simulateLoading();
            },
            offset: const Offset(0, 40),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: c.bgPrimary,
                border: Border.all(color: c.borderDefault),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedAsset,
                    style: AppTextStyles.mono(
                        size: 12,
                        weight: FontWeight.w700,
                        color: c.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  Icon(PhosphorIcons.caretDown(),
                      size: 14, color: AppColors.accentAmber),
                ],
              ),
            ),
            itemBuilder: (context) => _assets
                .map((a) => PopupMenuItem(
                      value: a,
                      child: Text(a,
                          style: AppTextStyles.mono(
                              size: 12, color: c.textPrimary)),
                    ))
                .toList(),
          ),
          const Spacer(),
          const _InlineStatLabel(value: "17", label: "NODES"),
          const SizedBox(width: 24),
          const _InlineStatLabel(value: "4", label: "PLATFORMS"),
          const SizedBox(width: 24),
          const _InlineStatLabel(value: "2.4M", label: "REACH"),
          const SizedBox(width: 24),
          const _InlineStatLabel(value: "2h 17m", label: "LATENCY"),
        ],
      ),
    );
  }

  static Widget _dot(Color color) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4)
          ],
        ),
      );

  Widget _buildGraphView(
      BuildContext context, AppThemeColors c, List<ContagionNode> nodes) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
                color: AppColors.accentAmber, strokeWidth: 2),
            const SizedBox(height: 16),
            Text("GENERATING FORENSIC PROPAGATION FLOW...",
                style: AppTextStyles.mono(size: 10, color: c.textMuted)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // STAGE HEADERS (Aligned to node columns)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: const Stack(
            children: [
              Align(alignment: Alignment(-0.76, 0), child: _StageHeader(label: "ORIGIN")),
              Align(alignment: Alignment(-0.3, 0), child: _StageHeader(label: "VECTORS")),
              Align(alignment: Alignment(0.2, 0), child: _StageHeader(label: "HUBS")),
              Align(alignment: Alignment(0.76, 0), child: _StageHeader(label: "ENDPOINTS")),
            ],
          ),
        ),
        Expanded(
          child: InteractiveViewer(
            minScale: 0.4,
            maxScale: 2.5,
            boundaryMargin: const EdgeInsets.all(200),
            child: Center(
              child: SizedBox(
                width: 1400,
                height: 800,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    final hitId = PropagationFlowPainter(
                      nodes: nodes,
                      animationValue: 0,
                      colors: c,
                    ).findNodeAt(details.localPosition, _nodePositions);

                    setState(() => _selectedNodeId = hitId);
                  },
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size.infinite,
                        painter: PropagationFlowPainter(
                          nodes: nodes,
                          selectedNodeId: _selectedNodeId,
                          animationValue: _controller.value,
                          colors: c,
                          onPositionsCalculated: (pos) => _nodePositions = pos,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StageHeader extends StatelessWidget {
  final String label;
  const _StageHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.bgSecondary,
        border: Border.all(color: context.colors.borderDefault),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: AppTextStyles.mono(
          size: 10,
          weight: FontWeight.w700,
          color: context.colors.textMuted,
          letterSpacing: 2,
        ),
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
            style: AppTextStyles.mono(
                size: 16,
                weight: FontWeight.w700,
                color: AppColors.accentAmber)),
        Text(label,
            style: AppTextStyles.mono(
                size: 8,
                color: c.textMuted,
                weight: FontWeight.w700,
                letterSpacing: 1)),
      ],
    );
  }
}
