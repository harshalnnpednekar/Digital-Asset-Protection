import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_colors.dart';
import 'contagion_mock_data.dart';
import 'widgets/contagion_graph_painter.dart';
import 'widgets/node_detail_sidebar.dart';
import 'package:graphview/graphview.dart' as gv;
import 'package:cloud_firestore/cloud_firestore.dart';

class PropagationFlowScreen extends StatefulWidget {
  final String? selectedThreatId;
  const PropagationFlowScreen({super.key, this.selectedThreatId});

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
    final selectedNode = _nodeById(_selectedNodeId, activeNodes);
    final parentNode = _nodeById(selectedNode?.parentId, activeNodes);

    final childCount = _selectedNodeId != null
        ? activeNodes.where((n) => n.parentId == _selectedNodeId).length
        : 0;

    return Scaffold(
      backgroundColor: c.bgPrimary,
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('contagion_nodes')
              .where('threat_id', isEqualTo: widget.selectedThreatId)
              .snapshots(),
          builder: (context, snapshot) {
            final hasData = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
            final useRealData = widget.selectedThreatId != null && hasData;

            return Padding(
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
                              useRealData
                                  ? "LIVE PROPAGATION MAP"
                                  : "PROPAGATION FLOW",
                              style: AppTextStyles.display(
                                size: 18,
                                weight: FontWeight.w800,
                                color: c.textPrimary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              useRealData
                                  ? "Real-time forensic trace for threat: ${widget.selectedThreatId}"
                                  : "Corporate forensic trace of unauthorized media distribution.",
                              style: AppTextStyles.body(
                                  size: 12, color: c.textMuted),
                            ),
                          ],
                        ),
                      ),
                      // Inline legend
                      Row(
                        children: [
                          _dot(AppColors.accentCrimson),
                          const SizedBox(width: 8),
                          Text("ROOT",
                              style: AppTextStyles.mono(
                                  size: 10,
                                  color: c.textMuted,
                                  weight: FontWeight.w700)),
                          const SizedBox(width: 20),
                          _dot(AppColors.accentAmber),
                          const SizedBox(width: 8),
                          Text("MIRROR",
                              style: AppTextStyles.mono(
                                  size: 10,
                                  color: c.textMuted,
                                  weight: FontWeight.w700)),
                          const SizedBox(width: 20),
                          _dot(c.accentBlue),
                          const SizedBox(width: 8),
                          Text("RESHARE",
                              style: AppTextStyles.mono(
                                  size: 10,
                                  color: c.textMuted,
                                  weight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  if (!useRealData) _buildAssetSelectorBar(c),
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
                            child: useRealData
                                ? _buildRealGraph(
                                    context, c, snapshot.data!.docs)
                                : _buildGraphView(context, c, activeNodes),
                          ),
                        ),

                        // SIDEBAR (Only for mock data, as requested real data uses tooltips/bottomsheets)
                        if (!useRealData && _selectedNodeId != null)
                          Positioned(
                            top: 0,
                            right: 0,
                            bottom: 0,
                            child: NodeDetailSidebar(
                              node: selectedNode,
                              parentNode: parentNode,
                              childCount: childCount,
                              onClose: () =>
                                  setState(() => _selectedNodeId = null),
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
            );
          }),
    );
  }

  ContagionNode? _nodeById(String? id, List<ContagionNode> nodes) {
    if (id == null) return null;
    for (final node in nodes) {
      if (node.id == id) return node;
    }
    return null;
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
              Align(
                  alignment: Alignment(-0.76, 0),
                  child: _StageHeader(label: "ORIGIN")),
              Align(
                  alignment: Alignment(-0.3, 0),
                  child: _StageHeader(label: "VECTORS")),
              Align(
                  alignment: Alignment(0.2, 0),
                  child: _StageHeader(label: "HUBS")),
              Align(
                  alignment: Alignment(0.76, 0),
                  child: _StageHeader(label: "ENDPOINTS")),
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

  Widget _buildRealGraph(BuildContext context, AppThemeColors c,
      List<QueryDocumentSnapshot> docs) {
    final graph = gv.Graph();
    final Map<String, gv.Node> nodeMap = {};

    // 1. Create nodes
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final nodeId = data['node_id'] ?? doc.id;
      final node = gv.Node.Id(nodeId);
      nodeMap[nodeId] = node;
      graph.addNode(node);
    }

    // 2. Create edges
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final nodeId = data['node_id'] ?? doc.id;
      final parentId = data['parent_id'];

      if (parentId != null && nodeMap.containsKey(parentId)) {
        graph.addEdge(nodeMap[parentId]!, nodeMap[nodeId]!);
      }
    }

    final builder = gv.BuchheimWalkerConfiguration()
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..orientation = (gv.BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT);

    return InteractiveViewer(
      minScale: 0.4,
      maxScale: 2.5,
      boundaryMargin: const EdgeInsets.all(200),
      child: Center(
        child: SizedBox(
          width: 1400,
          height: 800,
          child: gv.GraphView(
            graph: graph,
            algorithm: gv.BuchheimWalkerAlgorithm(
                builder, gv.TreeEdgeRenderer(builder)),
            paint: Paint()
              ..color = c.borderDefault
              ..strokeWidth = 1
              ..style = PaintingStyle.stroke,
            builder: (gv.Node node) {
              final nodeId = node.key!.value as String;
              final doc = docs.firstWhere((d) {
                final dData = d.data() as Map<String, dynamic>;
                return (dData['node_id'] ?? d.id) == nodeId;
              });
              final data = doc.data() as Map<String, dynamic>;

              return _buildNodeWidget(data, c);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNodeWidget(Map<String, dynamic> data, AppThemeColors c) {
    final type = data['type'] ?? 'SOCIAL_RESHARE';
    final platform = data['platform'] ?? 'Unknown';
    final label = data['label'] ?? 'Unknown Source';

    Color bgColor;
    Color textColor = Colors.white;

    switch (type) {
      case 'ROOT':
        bgColor = AppColors.accentCrimson;
        break;
      case 'MIRROR':
        bgColor = AppColors.accentAmber;
        textColor = AppColors.textOnAmber;
        break;
      case 'SOCIAL_RESHARE':
      default:
        bgColor = c.accentBlue;
        break;
    }

    return GestureDetector(
      onTap: () => _showNodeDetails(data),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              platform.toString().toUpperCase(),
              style: AppTextStyles.mono(
                size: 10,
                weight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.mono(
                size: 9,
                color: textColor.withAlpha(204),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showNodeDetails(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final c = context.colors;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: c.bgSecondary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: c.borderDefault),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "NODE FORENSICS",
                    style: AppTextStyles.mono(
                      size: 12,
                      weight: FontWeight.w800,
                      color: c.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                  IconButton(
                    icon: Icon(PhosphorIcons.x(), size: 20, color: c.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _detailRow("PLATFORM", data['platform'] ?? 'N/A'),
              _detailRow("URL/LABEL", data['label'] ?? 'N/A'),
              _detailRow("THREAT ID", data['threat_id'] ?? 'N/A'),
              _detailRow("TYPE", data['type'] ?? 'N/A'),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.mono(
                size: 10,
                color: c.textMuted,
                weight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.mono(
                size: 11,
                color: c.textPrimary,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
