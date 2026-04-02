import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme_colors.dart';

class AstraLogo extends StatelessWidget {
  final bool isLarge;

  const AstraLogo({super.key, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final double mainFontSize = isLarge ? 32 : 16;
    final double subFontSize = isLarge ? 11 : 8;
    final double markSize = isLarge ? 48 : 24;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // THE ASTRA MARK (Geometric A-Shield)
        _AstraMark(size: markSize, color: AppColors.accentAmber),
        SizedBox(width: isLarge ? 14 : 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "ASTRA",
                style: AppTextStyles.display(
                  size: mainFontSize,
                  weight: FontWeight.w800,
                  color: c.textPrimary,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                "MEDIA PROTECTION",
                style: AppTextStyles.display(
                  size: subFontSize,
                  weight: FontWeight.w600,
                  color: c.textMuted,
                  letterSpacing: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AstraMark extends StatelessWidget {
  final double size;
  final Color color;

  const _AstraMark({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Tactical Ring
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
            ),
          ),
          // Geometric Triangle (The 'A' Core)
          CustomPaint(
            size: Size(size * 0.7, size * 0.7),
            painter: _AstraPainter(color: color),
          ),
        ],
      ),
    );
  }
}

class _AstraPainter extends CustomPainter {
  final Color color;
  _AstraPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = Colors.white.withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = 1.5;

    final path = Path();
    // A-Shield Triangle
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * 0.8, size.height);
    path.lineTo(size.width / 2, size.height * 0.4);
    path.lineTo(size.width * 0.2, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    // Tactical crossbar
    final barRect = Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.75), width: size.width * 0.4, height: 2);
    canvas.drawRect(barRect, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
