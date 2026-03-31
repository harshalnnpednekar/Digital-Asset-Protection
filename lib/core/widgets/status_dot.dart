import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StatusDot extends StatelessWidget {
  final Color color;
  final double size;

  const StatusDot({
    super.key,
    required this.color,
    this.size = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 2.5,
      height: size * 2.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulsing ring
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.3),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(2.5, 2.5),
            duration: const Duration(milliseconds: 2000),
            curve: Curves.easeOut,
          )
          .fade(
            begin: 1.0,
            end: 0.0,
            duration: const Duration(milliseconds: 2000),
            curve: Curves.easeOut,
          ),
          // Inner solid dot
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
