import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ConfidenceCircle extends StatefulWidget {
  final String label;
  final double value;

  const ConfidenceCircle({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  State<ConfidenceCircle> createState() => _ConfidenceCircleState();
}

class _ConfidenceCircleState extends State<ConfidenceCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ConfidenceCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: 0, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color arcColor;
    if (widget.value > 0.85) {
      arcColor = AppColors.accentCrimson;
    } else if (widget.value > 0.65) {
      arcColor = AppColors.accentAmber;
    } else {
      arcColor = AppColors.accentGreen;
    }

    return Column(
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            children: [
              Center(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(140, 140),
                      painter: _ArcPainter(
                        value: _animation.value,
                        color: arcColor,
                      ),
                    );
                  },
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${(widget.value * 100).toStringAsFixed(1)}%",
                      style: AppTextStyles.mono(size: 26, weight: FontWeight.w700, color: arcColor),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        widget.label,
                        style: AppTextStyles.mono(size: 8, color: AppColors.textMuted, letterSpacing: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double value;
  final Color color;

  _ArcPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background track
    final bgPaint = Paint()
      ..color = AppColors.bgTertiary
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Foreground arc
    final arcPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * value,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
