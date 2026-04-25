import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../contagion_mock_data.dart';

class PropagationFlowPainter extends CustomPainter {
  final List<ContagionNode> nodes;
  final String? selectedNodeId;
  final double animationValue;
  final AppThemeColors colors;
  final Function(Map<String, Offset>)? onPositionsCalculated;

  PropagationFlowPainter({
    required this.nodes,
    this.selectedNodeId,
    required this.animationValue,
    required this.colors,
    this.onPositionsCalculated,
  });

  final Map<String, Offset> nodePositions = {};

  // STAGE DEFINITIONS (Linear Forensics)
  // S1: SOURCE (Origin Core)
  // S2: VECTOR (Extraction point)
  // S3: HUB (Primary distribution node)
  // S4: ENDPOINTS (Marketplaces/Platforms)

  void _calculatePositions(Size size) {
    nodePositions.clear();
    final double w = size.width;
    final double h = size.height;

    final tierOrder = ['ROOT', 'T1', 'T2', 'T3'];
    final tierX = <String, double>{
      'ROOT': 0.12,
      'T1': 0.35,
      'T2': 0.62,
      'T3': 0.88,
    };
    final nodesByTier = <String, List<ContagionNode>>{};

    for (final node in nodes) {
      nodesByTier.putIfAbsent(node.tier, () => <ContagionNode>[]).add(node);
    }

    for (final tier in tierOrder) {
      final tierNodes = nodesByTier[tier];
      if (tierNodes == null || tierNodes.isEmpty) {
        continue;
      }

      tierNodes.sort((a, b) {
        final aIndex = int.tryParse(a.id.replaceAll(RegExp(r'\D'), '')) ?? 0;
        final bIndex = int.tryParse(b.id.replaceAll(RegExp(r'\D'), '')) ?? 0;
        return aIndex.compareTo(bIndex);
      });

      final x = w * tierX[tier]!;
      final top = tier == 'ROOT' ? 0.5 : 0.12;
      final bottom = tier == 'ROOT' ? 0.5 : 0.88;

      for (var index = 0; index < tierNodes.length; index++) {
        final progress =
            tierNodes.length == 1 ? 0.5 : index / (tierNodes.length - 1);
        final y = h * (top + (bottom - top) * progress);
        nodePositions[tierNodes[index].id] = Offset(x, y);
      }
    }

    if (onPositionsCalculated != null) {
      onPositionsCalculated!(Map.from(nodePositions));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _calculatePositions(size);
    _drawForegroundGrid(canvas, size);

    // 1. Draw Forensic Connections (Orthogonal)
    for (final node in nodes) {
      if (node.parentId != null && nodePositions.containsKey(node.parentId)) {
        _drawOrthogonalEdge(canvas, nodePositions[node.parentId]!,
            nodePositions[node.id]!, node.tier);
      }
    }

    // 2. Draw Forensic Data Nodes
    for (final node in nodes) {
      _drawStageNode(canvas, nodePositions[node.id]!, node);
    }
  }

  void _drawForegroundGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors.textMuted.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    const spacing = 100.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawOrthogonalEdge(
      Canvas canvas, Offset start, Offset end, String tier) {
    final path = Path()..moveTo(start.dx, start.dy);

    // Linear orthogonal connection
    final midX = start.dx + (end.dx - start.dx) / 2;
    path.lineTo(midX, start.dy);
    path.lineTo(midX, end.dy);
    path.lineTo(end.dx, end.dy);

    final color = _getTierColor(tier).withValues(alpha: 0.4);
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);

    // Signal Pulse along Orthogonal Path
    _drawSignalPulse(canvas, start, midX, end, tier);
  }

  void _drawSignalPulse(
      Canvas canvas, Offset start, double midX, Offset end, String tier) {
    final totalLen = (midX - start.dx).abs() +
        (end.dy - start.dy).abs() +
        (end.dx - midX).abs();
    final d1 = (midX - start.dx).abs();
    final d2 = (end.dy - start.dy).abs();

    final travel = totalLen * animationValue;
    Offset pos;

    if (travel < d1) {
      pos = Offset(start.dx + travel, start.dy);
    } else if (travel < d1 + d2) {
      pos =
          Offset(midX, start.dy + (travel - d1) * (end.dy > start.dy ? 1 : -1));
    } else {
      pos = Offset(midX + (travel - d1 - d2), end.dy);
    }

    final color = _getTierColor(tier);
    canvas.drawCircle(pos, 3, Paint()..color = color);
    canvas.drawCircle(pos, 6, Paint()..color = color.withValues(alpha: 0.2));
  }

  void _drawStageNode(Canvas canvas, Offset pos, ContagionNode node) {
    final isSelected = node.id == selectedNodeId;
    final nodeColor = _getTierColor(node.tier);
    final bool isEndpoint = node.tier == "T3";

    final width = isEndpoint ? 90.0 : 110.0;
    final height = isEndpoint ? 24.0 : 36.0;

    final rect = Rect.fromCenter(center: pos, width: width, height: height);
    // Corporate sharp edges

    // Selection Glow
    if (isSelected) {
      canvas.drawRect(rect.inflate(4),
          Paint()..color = AppColors.accentAmber.withValues(alpha: 0.15));
      canvas.drawRect(
          rect.inflate(1),
          Paint()
            ..color = AppColors.accentAmber
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }

    // Node Body
    canvas.drawRect(rect, Paint()..color = colors.bgPrimary);
    canvas.drawRect(
        rect,
        Paint()
          ..color = nodeColor.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    // Left Accent Bar
    canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, 3, rect.height),
        Paint()..color = nodeColor);

    // Node Details
    _drawForensicData(canvas, rect, node, nodeColor, isEndpoint);
  }

  void _drawForensicData(Canvas canvas, Rect rect, ContagionNode node,
      Color color, bool isEndpoint) {
    // A. TITLE / ID
    final titleTp = _createTextPainter(
      isEndpoint ? node.platform.toUpperCase() : node.id.toUpperCase(),
      fontSize: isEndpoint ? 8 : 9,
      fontWeight: FontWeight.w800,
      color: colors.textPrimary,
      isMono: true,
    );
    titleTp.paint(
        canvas, Offset(rect.left + 10, rect.top + (isEndpoint ? 7 : 8)));

    if (!isEndpoint) {
      // B. SUBTITLE (IP or Stage)
      final subTp = _createTextPainter(
        node.ipAddress,
        fontSize: 7,
        fontWeight: FontWeight.w600,
        color: colors.textMuted,
        isMono: true,
      );
      subTp.paint(canvas, Offset(rect.left + 10, rect.top + 20));
    }
  }

  TextPainter _createTextPainter(
    String text, {
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    bool isMono = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: isMono ? 'IBM Plex Mono' : 'Outfit',
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    return tp;
  }

  Color _getTierColor(String tier) {
    if (tier == "ROOT") return AppColors.accentCrimson;
    if (tier == "T1") return AppColors.accentAmber;
    return colors.accentBlue;
  }

  @override
  bool shouldRepaint(covariant PropagationFlowPainter oldDelegate) => true;

  String? findNodeAt(Offset localPosition, Map<String, Offset> positions) {
    for (final entry in positions.entries) {
      final rect = Rect.fromCenter(center: entry.value, width: 140, height: 50);
      if (rect.contains(localPosition)) return entry.key;
    }
    return null;
  }
}
