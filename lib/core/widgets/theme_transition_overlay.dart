import 'package:flutter/material.dart';

class ThemeTransitionService {
  static OverlayEntry? _entry;

  static Future<void> playTransition(BuildContext context, bool toLight) async {
    final overlay = Overlay.of(context);

    _entry = OverlayEntry(
      builder: (ctx) => _ThemeFlashOverlay(toLight: toLight),
    );

    overlay.insert(_entry!);

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 400));

    _entry?.remove();
    _entry = null;
  }
}

class _ThemeFlashOverlay extends StatefulWidget {
  final bool toLight;
  const _ThemeFlashOverlay({required this.toLight});

  @override
  State<_ThemeFlashOverlay> createState() => _ThemeFlashOverlayState();
}

class _ThemeFlashOverlayState extends State<_ThemeFlashOverlay>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Quick flash: opacity goes 0 → 0.25 → 0
    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.25), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.25, end: 0.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) => IgnorePointer(
        child: Container(
          color: (widget.toLight
            ? Colors.white
            : Colors.black
          ).withValues(alpha: _opacity.value),
        ),
      ),
    );
  }
}
