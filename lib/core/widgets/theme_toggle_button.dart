import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme_colors.dart';
import '../theme/app_colors.dart';
import 'theme_transition_overlay.dart';

class ThemeToggleButton extends ConsumerStatefulWidget {
  final bool compact;
  const ThemeToggleButton({super.key, this.compact = false});

  @override
  ConsumerState<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends ConsumerState<ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _spinController;
  bool _isHovering = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isAnimating) return;
    setState(() => _isAnimating = true);

    final isDark = ref.read(isDarkProvider);

    // Start icon spin
    _spinController.forward();

    // Play the screen flash at midpoint of spin (300ms in)
    await Future.delayed(const Duration(milliseconds: 280));
    if (mounted) {
      await ThemeTransitionService.playTransition(context, isDark);
    }

    // Switch theme
    ref.read(themeModeProvider.notifier).state =
      isDark ? ThemeMode.light : ThemeMode.dark;

    // Finish icon spin
    await _spinController.forward();
    _spinController.reset();

    setState(() => _isAnimating = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkProvider);
    final c = context.colors;

    if (widget.compact) {
      return _buildCompact(isDark, c);
    }

    return _buildSidebar(isDark, c);
  }

  Widget _buildCompact(bool isDark, AppThemeColors c) {
    return Tooltip(
      message: isDark ? 'Switch to Light Mode (Ctrl+Shift+L)' : 'Switch to Dark Mode (Ctrl+Shift+L)',
      textStyle: GoogleFonts.ibmPlexMono(fontSize: 11, color: Colors.white),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2330),
        borderRadius: BorderRadius.zero,
      ),
      waitDuration: const Duration(milliseconds: 600),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _toggle,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 100),
            scale: _isHovering ? 1.05 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _isHovering ? AppColors.accentAmber.withValues(alpha: 0.12) : c.bgTertiary,
                border: Border.all(
                  color: _isHovering ? AppColors.accentAmber : c.borderDefault,
                  width: 1,
                ),
              ),
              child: Center(
                child: RotationTransition(
                  turns: _spinController,
                  child: Icon(
                    isDark ? PhosphorIcons.moon() : PhosphorIcons.sun(),
                    size: 16,
                    color: AppColors.accentAmber,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(bool isDark, AppThemeColors c) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          height: 38,
          decoration: BoxDecoration(
            color: c.bgTertiary,
            border: Border.all(color: c.borderDefault),
          ),
          child: Stack(
            children: [
              // Sliding active indicator
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: isDark ? Alignment.centerLeft : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.accentAmber.withValues(alpha: 0.08),
                      border: Border(
                        left: isDark
                          ? const BorderSide(color: AppColors.accentAmber, width: 2)
                          : BorderSide.none,
                        right: !isDark
                          ? const BorderSide(color: AppColors.accentAmber, width: 2)
                          : BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              // Labels
              Row(
                children: [
                   Expanded(
                     child: Center(
                       child: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Icon(PhosphorIcons.moon(), size: 12, color: isDark ? AppColors.accentAmber : c.textMuted),
                           const SizedBox(width: 8),
                           Text(
                             "DARK",
                             style: GoogleFonts.ibmPlexMono(
                               fontSize: 10,
                               fontWeight: FontWeight.w700,
                               color: isDark ? AppColors.accentAmber : c.textMuted,
                               letterSpacing: 1,
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                   Expanded(
                     child: Center(
                       child: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Icon(PhosphorIcons.sun(), size: 12, color: !isDark ? AppColors.accentAmber : c.textMuted),
                           const SizedBox(width: 8),
                           Text(
                             "LIGHT",
                             style: GoogleFonts.ibmPlexMono(
                               fontSize: 10,
                               fontWeight: FontWeight.w700,
                               color: !isDark ? AppColors.accentAmber : c.textMuted,
                               letterSpacing: 1,
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
