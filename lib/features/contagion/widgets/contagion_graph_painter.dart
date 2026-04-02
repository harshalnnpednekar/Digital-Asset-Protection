import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../contagion_mock_data.dart';

class ContagionGraphPainter extends CustomPainter {
  final List<ContagionNode> nodes;
  final String? selectedNodeId;
  final double animationValue;
  final AppThemeColors colors;
  
  // Callback to return calculated positions to the parent for tap detection
  final Function(Map<String, Offset>)? onPositionsCalculated;

  ContagionGraphPainter({
    required this.nodes,
    this.selectedNodeId,
    required this.animationValue,
    required this.colors,
    this.onPositionsCalculated,
  });

  final Map<String, Offset> nodePositions = {};

  void _calculatePositions(Size size) {
    nodePositions.clear();

    final double w = size.width;
    final double h = size.height;

    // ROOT
    nodePositions["N0"] = Offset(w / 2, h * 0.12);

    // TIER 1
    nodePositions["N1"] = Offset(w * 0.18, h * 0.35);
    nodePositions["N2"] = Offset(w * 0.50, h * 0.35);
    nodePositions["N3"] = Offset(w * 0.82, h * 0.35);

    // TIER 2
    nodePositions["N4"] = Offset(w * 0.08, h * 0.60);
    nodePositions["N5"] = Offset(w * 0.22, h * 0.60);
    nodePositions["N6"] = Offset(w * 0.40, h * 0.60);
    nodePositions["N7"] = Offset(w * 0.58, h * 0.60);
    nodePositions["N8"] = Offset(w * 0.74, h * 0.60);
    nodePositions["N9"] = Offset(w * 0.90, h * 0.60);

    // TIER 3
    nodePositions["N10"] = Offset(w * 0.04, h * 0.85);
    nodePositions["N11"] = Offset(w * 0.13, h * 0.85);
    nodePositions["N12"] = Offset(w * 0.25, h * 0.85);
    nodePositions["N13"] = Offset(w * 0.38, h * 0.85);
    nodePositions["N14"] = Offset(w * 0.50, h * 0.85);
    nodePositions["N15"] = Offset(w * 0.66, h * 0.85);
    nodePositions["N16"] = Offset(w * 0.80, h * 0.85);
    nodePositions["N17"] = Offset(w * 0.94, h * 0.85);

    // Notify parent if needed (using postFrameCallback or similar mechanism usually, 
    // but here we just need them for hit testing in the GestureDetector)
    if (onPositionsCalculated != null) {
      onPositionsCalculated!(Map.from(nodePositions));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _calculatePositions(size);

    _drawDotGrid(canvas, size);

    // 1. Draw Edges (Background)
    for (final node in nodes) {
      if (node.parentId != null && nodePositions.containsKey(node.parentId)) {
        _drawEdge(canvas, nodePositions[node.parentId]!, nodePositions[node.id]!, node.tier);
      }
    }

    // 2. Draw Moving Pulses (Flow)
    for (final node in nodes) {
      if (node.parentId != null && nodePositions.containsKey(node.parentId)) {
        _drawPulse(canvas, nodePositions[node.parentId]!, nodePositions[node.id]!, node.tier);
      }
    }

    // 3. Draw Nodes (Top Layer)
    for (final node in nodes) {
      _drawNode(canvas, nodePositions[node.id]!, node);
    }
  }

  void _drawDotGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors.textMuted.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.5, paint);
      }
    }
  }

  void _drawEdge(Canvas canvas, Offset start, Offset end, String tier) {
    final path = Path()..moveTo(start.dx, start.dy);
    final cp1 = Offset(start.dx, start.dy + (end.dy - start.dy) * 0.4);
    final cp2 = Offset(end.dx, start.dy + (end.dy - start.dy) * 0.6);
    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

    final color = _getTierColor(tier).withValues(alpha: 0.25);
    canvas.drawPath(path, Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (tier == "T1" ? 2.5 : 1.5));
  }

  void _drawPulse(Canvas canvas, Offset start, Offset end, String tier) {
    final path = Path()..moveTo(start.dx, start.dy);
    final cp1 = Offset(start.dx, start.dy + (end.dy - start.dy) * 0.4);
    final cp2 = Offset(end.dx, start.dy + (end.dy - start.dy) * 0.6);
    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

    final metrics = path.computeMetrics();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    
    // Draw two pulses for continuity
    _drawPulseAt(canvas, metric, animationValue, tier);
    _drawPulseAt(canvas, metric, (animationValue + 0.5) % 1.0, tier);
  }

  void _drawPulseAt(Canvas canvas, PathMetric metric, double val, String tier) {
    final tangent = metric.getTangentForOffset(metric.length * val);
    if (tangent == null) return;

    final color = _getTierColor(tier);
    canvas.drawCircle(tangent.position, 3.5, Paint()..color = color);
    canvas.drawCircle(tangent.position, 8, Paint()..color = color.withValues(alpha: 0.15));
  }

  void _drawNode(Canvas canvas, Offset pos, ContagionNode node) {
    final isSelected = node.id == selectedNodeId;
    final isRoot = node.tier == "ROOT";
    final nodeColor = _getTierColor(node.tier);
    final radius = isRoot ? 24.0 : (node.tier == "T1" ? 18.0 : 14.0);

    // 1. Glow effect
    canvas.drawCircle(pos, radius * 2, Paint()
      ..shader = RadialGradient(
        colors: [nodeColor.withValues(alpha: 0.2), Colors.transparent],
      ).createShader(Rect.fromCircle(center: pos, radius: radius * 2)));

    // 2. Selection indicator
    if (isSelected) {
      canvas.drawCircle(pos, radius + 10, Paint()
        ..color = AppColors.accentAmber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
    }

    // 3. Main Node Circle
    canvas.drawCircle(pos, radius, Paint()..color = colors.bgPrimary);
    canvas.drawCircle(pos, radius, Paint()
      ..color = nodeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);
    
    // Core solid dot for root and T1
    if (isRoot || node.tier == "T1") {
       canvas.drawCircle(pos, radius * 0.4, Paint()..color = nodeColor);
    }

    // 4. FORENSIC LABELS (The "Info" requested)
    _drawLabels(canvas, pos, radius, node, nodeColor);
  }

  void _drawLabels(Canvas canvas, Offset pos, double radius, ContagionNode node, Color nodeColor) {
    // A. PLATFORM BADGE
    final platformTp = _createTextPainter(
      node.platform.toUpperCase(),
      fontSize: 9,
      fontWeight: FontWeight.w900,
      color: colors.bgPrimary,
    );
    
    final badgeWidth = platformTp.width + 12;
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy - radius - 12), width: badgeWidth, height: 16),
      const Radius.circular(2),
    );
    canvas.drawRRect(badgeRect, Paint()..color = nodeColor);
    platformTp.paint(canvas, Offset(pos.dx - platformTp.width / 2, pos.dy - radius - 19));

    // B. IP ADDRESS (Forensic ID)
    final ipTp = _createTextPainter(
      node.ipAddress,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: nodeColor,
      isMono: true,
    );
    ipTp.paint(canvas, Offset(pos.dx - ipTp.width / 2, pos.dy + radius + 8));

    // C. REACH/STRENGTH
    final reachTp = _createTextPainter(
      node.estimatedReach,
      fontSize: 8,
      fontWeight: FontWeight.w600,
      color: colors.textMuted,
    );
    reachTp.paint(canvas, Offset(pos.dx - reachTp.width / 2, pos.dy + radius + 22));
  }

  TextPainter _createTextPainter(String text, {
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
          fontFamily: isMono ? 'IBM Plex Mono' : 'Inter',
          letterSpacing: 0.5,
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
  bool shouldRepaint(covariant ContagionGraphPainter oldDelegate) => true;

  // Manual hit testing helper
  String? findNodeAt(Offset localPosition, Map<String, Offset> positions) {
    for (final entry in positions.entries) {
      final dist = (localPosition - entry.value).distance;
      if (dist < 35) return entry.key;
    }
    return null;
  }
}
