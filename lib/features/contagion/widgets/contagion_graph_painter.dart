import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../contagion_mock_data.dart';

class ContagionGraphPainter extends CustomPainter {
  final List<ContagionNode> nodes;
  final String? selectedNodeId;
  final double animationValue; // 0.0 to 1.0 for the traveling dots
  final AppThemeColors colors;

  ContagionGraphPainter({
    required this.nodes,
    this.selectedNodeId,
    required this.animationValue,
    required this.colors,
  });

  // Position map to store calculated coordinates
  final Map<String, Offset> nodePositions = {};

  void _calculatePositions(Size size) {
    if (nodePositions.isNotEmpty) return;

    final double w = size.width;

    // ROOT
    nodePositions["N0"] = Offset(w / 2, 80);

    // T1 (Directly from N0)
    nodePositions["N1"] = Offset(w * 0.2, 220);
    nodePositions["N2"] = Offset(w * 0.5, 220);
    nodePositions["N3"] = Offset(w * 0.8, 220);

    // T2
    nodePositions["N4"] = Offset(w * 0.12, 380);
    nodePositions["N5"] = Offset(w * 0.28, 380);
    nodePositions["N6"] = Offset(w * 0.42, 380);
    nodePositions["N7"] = Offset(w * 0.58, 380);
    nodePositions["N8"] = Offset(w * 0.72, 380);
    nodePositions["N9"] = Offset(w * 0.88, 380);

    // T3
    nodePositions["N10"] = Offset(w * 0.08, 540);
    nodePositions["N11"] = Offset(w * 0.16, 540);
    nodePositions["N12"] = Offset(w * 0.28, 540);
    nodePositions["N13"] = Offset(w * 0.42, 540);
    nodePositions["N14"] = Offset(w * 0.58, 540);
    nodePositions["N15"] = Offset(w * 0.72, 540);
    nodePositions["N16"] = Offset(w * 0.84, 540);
    nodePositions["N17"] = Offset(w * 0.92, 540);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _calculatePositions(size);

    // 1. DRAW BACKGROUND DOT GRID
    final dotColor = colors.isDark ? const Color(0xFF1E2330) : colors.borderDefault.withAlpha(50);
    final dotPaint = Paint()..color = dotColor;
    const double spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }

    // 2. DRAW EDGES
    for (final node in nodes) {
      if (node.parentId != null && nodePositions.containsKey(node.parentId)) {
        final start = nodePositions[node.parentId]!;
        final end = nodePositions[node.id]!;
        _drawEdge(canvas, start, end, node.tier);
      }
    }

    // 3. DRAW TRAVELING DOTS
    for (final node in nodes) {
      if (node.parentId != null && nodePositions.containsKey(node.parentId)) {
        final start = nodePositions[node.parentId]!;
        final end = nodePositions[node.id]!;
        _drawTravelingDot(canvas, start, end, node.tier);
      }
    }

    // 4. DRAW NODES
    for (final node in nodes) {
      final pos = nodePositions[node.id]!;
      _drawNode(canvas, pos, node);
    }
  }

  void _drawEdge(Canvas canvas, Offset start, Offset end, String tier) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Curved path using cubic bezier for elegant flow
    final controlPoint1 =
        Offset(start.dx, start.dy + (end.dy - start.dy) * 0.5);
    final controlPoint2 = Offset(end.dx, start.dy + (end.dy - start.dy) * 0.5);
    path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
        controlPoint2.dy, end.dx, end.dy);

    double strokeWidth = 1.0;
    Color color = colors.borderDefault.withAlpha(128);

    if (tier == "T1") {
      strokeWidth = 2.0;
      color = AppColors.accentCrimson.withAlpha(180); // Root to T1
    } else if (tier == "T2") {
      strokeWidth = 1.5;
      color = AppColors.accentAmber.withAlpha(180); // T1 to T2
    } else {
      strokeWidth = 1.2;
      color = colors.accentBlue.withAlpha(150); // T2 to T3
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawPath(path, paint);
  }

  void _drawTravelingDot(Canvas canvas, Offset start, Offset end, String tier) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    final controlPoint1 =
        Offset(start.dx, start.dy + (end.dy - start.dy) * 0.5);
    final controlPoint2 = Offset(end.dx, start.dy + (end.dy - start.dy) * 0.5);
    path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
        controlPoint2.dy, end.dx, end.dy);

    final pathMetrics = path.computeMetrics();
    if (pathMetrics.isEmpty) return;
    final metric = pathMetrics.first;

    final tangent = metric.getTangentForOffset(metric.length * animationValue);
    if (tangent != null) {
      Color dotColor;
      if (tier == "T1") {
        dotColor = AppColors.accentCrimson;
      } else if (tier == "T2") {
        dotColor = AppColors.accentAmber;
      } else {
        dotColor = colors.accentBlue;
      }

      final paint = Paint()
        ..color = dotColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(tangent.position, 4.0, paint);

      // Outer glow
      canvas.drawCircle(
          tangent.position, 7.0, Paint()..color = dotColor.withAlpha(100));
    }
  }

  void _drawNode(Canvas canvas, Offset pos, ContagionNode node) {
    final bool isSelected = node.id == selectedNodeId;

    if (node.tier == "ROOT") {
      // GLOW
      canvas.drawCircle(
          pos, 50, Paint()..color = AppColors.accentCrimson.withAlpha(38));

      // HEXAGON
      final path = Path();
      const double radius = 18.0;
      for (int i = 0; i < 6; i++) {
        final double angle = (i * 60) * math.pi / 180;
        final double x = pos.dx + radius * math.cos(angle);
        final double y = pos.dy + radius * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, Paint()..color = AppColors.accentCrimson);
      canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    } else if (node.tier == "T1") {
      // GLOW
      canvas.drawCircle(
          pos, 38, Paint()..color = AppColors.accentAmber.withAlpha(26));

      canvas.drawCircle(pos, 13, Paint()..color = AppColors.accentAmber);
      canvas.drawCircle(
          pos,
          13,
          Paint()
            ..color = AppColors.accentAmber
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    } else if (node.tier == "T2") {
      canvas.drawCircle(pos, 10, Paint()..color = colors.bgTertiary);
      canvas.drawCircle(
          pos,
          10,
          Paint()
            ..color = colors.borderDefault
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
      canvas.drawCircle(pos, 3, Paint()..color = colors.accentBlue);
    } else {
      // T3
      final rect = Rect.fromCenter(center: pos, width: 16, height: 16);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()..color = colors.bgSecondary);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()
            ..color = colors.borderDefault
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
    }

    // SELECTION RING
    if (isSelected) {
      canvas.drawCircle(
          pos,
          24,
          Paint()
            ..color = AppColors.accentAmber
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }

    // LABEL
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.label.length > 18
            ? "${node.label.substring(0, 15)}..."
            : node.label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: node.tier == "ROOT"
              ? AppColors.accentCrimson
              : colors.textPrimary,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas, Offset(pos.dx - textPainter.width / 2, pos.dy + 20));
  }

  @override
  bool shouldRepaint(covariant ContagionGraphPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.selectedNodeId != selectedNodeId ||
        oldDelegate.colors != colors;
  }

  // Helper for tap detection
  String? findNodeAt(Offset localPosition) {
    for (final entry in nodePositions.entries) {
      final double dist = (localPosition - entry.value).distance;
      if (dist < 25) return entry.key;
    }
    return null;
  }
}
