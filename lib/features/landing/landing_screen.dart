import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/astra_logo.dart';
import '../../core/widgets/theme_toggle_button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    
    return Scaffold(
      backgroundColor: c.bgPrimary,
      body: Stack(
        children: [
          // CENTERED CONTENT
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
              child: isWide 
                ? _DesktopLayout(isWide: isWide) 
                : const _MobileLayout(),
            ),
          ),

          // TOP BAR (Theme Toggle)
          Positioned(
            top: 24,
            right: 24,
            child: const ThemeToggleButton(compact: true)
                .animate()
                .fadeIn(delay: 800.ms),
          ),
        ],
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final bool isWide;
  const _DesktopLayout({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AstraLogo(
              size: isWide ? 180 : 120, // Massive boost for hero prominence
              showText: true,
            ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack).fadeIn(),
            const SizedBox(height: 80),
            _HeadlineBlock(isWide: isWide),
            const SizedBox(height: 64),
            const _CTASection(),
          ],
        ),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AstraLogo(
              size: 120, // Massive boost for mobile hero
              showText: true,
            ).animate().fadeIn().scale(),
            const SizedBox(height: 64),
            const _HeadlineBlock(isWide: false),
            const SizedBox(height: 48),
            const _CTASection(),
          ],
        ),
      ),
    );
  }
}

class _HeadlineBlock extends StatelessWidget {
  final bool isWide;
  const _HeadlineBlock({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fontSize = isWide ? 88.0 : 56.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "ZERO TRUST",
          textAlign: TextAlign.center,
          style: AppTextStyles.display(
            size: fontSize,
            weight: FontWeight.w900,
            color: c.textPrimary,
            height: 1.0,
            letterSpacing: -2,
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 800.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          "TOTAL CUSTODY",
          textAlign: TextAlign.center,
          style: AppTextStyles.display(
            size: fontSize,
            weight: FontWeight.w900,
            color: AppColors.accentAmber,
            height: 1.0,
            letterSpacing: -2,
          ),
        ).animate().fadeIn(delay: 450.ms, duration: 800.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 40),
        Text(
          "ENTERPRISE ASSET PROTECTION FOR MODERN MEDIA",
          textAlign: TextAlign.center,
          style: AppTextStyles.mono(
            size: 14,
            weight: FontWeight.w600,
            color: c.textMuted,
            letterSpacing: 4,
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }
}

class _CTASection extends StatelessWidget {
  const _CTASection();

  @override
  Widget build(BuildContext context) {
    return const _LandingCTAButton()
        .animate()
        .fadeIn(delay: 750.ms)
        .slideY(begin: 0.2, end: 0);
  }
}

class _LandingCTAButton extends StatefulWidget {
  const _LandingCTAButton();

  @override
  State<_LandingCTAButton> createState() => _LandingCTAButtonState();
}

class _LandingCTAButtonState extends State<_LandingCTAButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/login'),
        child: AnimatedContainer(
          duration: 300.ms,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          decoration: BoxDecoration(
            color: _isHovering ? AppColors.accentAmber : Colors.transparent,
            border: Border.all(
              color: AppColors.accentAmber,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "INITIALIZE PROTECTED SESSION",
                style: AppTextStyles.display(
                  size: 16,
                  weight: FontWeight.w800,
                  color: _isHovering ? AppColors.textOnAmber : AppColors.accentAmber,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 24),
              AnimatedPadding(
                duration: 300.ms,
                padding: EdgeInsets.only(left: _isHovering ? 12 : 0),
                child: Icon(
                  PhosphorIcons.arrowRight(),
                  color: _isHovering ? AppColors.textOnAmber : AppColors.accentAmber,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Unused components removed for centering and cleanup.
