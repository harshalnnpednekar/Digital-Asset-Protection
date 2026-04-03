import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme_colors.dart';

class AstraLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isLight;

  const AstraLogo({
    super.key, 
    this.size = 24, 
    this.showText = true,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = isLight ? Colors.white : AppColors.accentAmber;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _LogoPainter(fillColor: color),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "ASTRA",
                style: AppTextStyles.display(
                  size: size * 0.95, // Massive scale for Hero prominence
                  weight: FontWeight.w900,
                  color: isLight ? Colors.white : c.textPrimary,
                  letterSpacing: 2,
                ),
              ),
              Text(
                "MEDIA PROTECTION LTD",
                style: AppTextStyles.display(
                  size: size * 0.28, // Boosted
                  weight: FontWeight.w700,
                  color: isLight ? Colors.white.withValues(alpha: 0.7) : c.textMuted,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color fillColor;
  const _LogoPainter({required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // Draw Hexagon
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Bullseye design
    final bgPaint = Paint()
      ..color = const Color(0xFF0A0C10)
      ..style = PaintingStyle.fill;
    
    // Rings
    canvas.drawCircle(Offset(centerX, centerY), radius * 0.7, bgPaint);
    
    final ringPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05;
    
    canvas.drawCircle(Offset(centerX, centerY), radius * 0.45, ringPaint);
    
    final corePaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), radius * 0.18, corePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
