import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/widgets/astra_logo.dart';
import '../../core/widgets/theme_toggle_button.dart';

double _fluidType(
  double width, {
  required double min,
  required double max,
  double base = 1200,
}) {
  final t = (width / base).clamp(0.0, 1.0);
  return min + ((max - min) * t);
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pageWidth = MediaQuery.of(context).size.width;
    final valueSize = _fluidType(pageWidth, min: 26, max: 36, base: 1400);

    return Scaffold(
      backgroundColor: c.bgPrimary,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    c.bgPrimary,
                    c.bgSecondary,
                    c.bgPrimary,
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
              top: -80,
              right: -60,
              child: _AnimatedBlob(size: 290, amber: true)),
          const Positioned(
              bottom: -120,
              left: -80,
              child: _AnimatedBlob(size: 340, amber: false)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 24),
              child: const Column(
                children: [
                  _TopNav(),
                  SizedBox(height: 24),
                  _HeroSection(),
                  SizedBox(height: 22),
                  _TrustStrip(),
                  SizedBox(height: 22),
                  _FeatureGrid(),
                  SizedBox(height: 22),
                  _CtaBand(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBlob extends StatelessWidget {
  final double size;
  final bool amber;

  const _AnimatedBlob({required this.size, required this.amber});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final base = amber ? AppColors.accentAmber : c.accentBlue;

    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              base.withValues(alpha: c.isDark ? 0.24 : 0.17),
              base.withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ),
        ),
      ).animate().fadeIn(duration: 900.ms),
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return _GlassShell(
      child: Row(
        children: [
          const AstraLogo(size: 24),
          const Spacer(),
          OutlinedButton(
            onPressed: () => context.go('/login'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: c.borderDefault.withValues(alpha: 0.8)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text(
              'Sign In',
              style: AppTextStyles.body(
                size: 13,
                weight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: () => context.go('/signup'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentAmber,
              foregroundColor: AppColors.textOnAmber,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text(
              'Get Started',
              style: AppTextStyles.display(
                size: 13,
                weight: FontWeight.w700,
                color: AppColors.textOnAmber,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const ThemeToggleButton(compact: true),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: -0.06, end: 0);
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 940;

    return _GlassShell(
      radius: 30,
      padding: const EdgeInsets.all(24),
      child: isWide
          ? const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: _HeroCopy()),
                SizedBox(width: 22),
                Expanded(flex: 5, child: _HeroVisual()),
              ],
            )
          : const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCopy(),
                SizedBox(height: 24),
                _HeroVisual(),
              ],
            ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pageWidth = MediaQuery.of(context).size.width;
    final compact = pageWidth < 650;
    final badgeSize = _fluidType(pageWidth, min: 10, max: 12, base: 900);
    final titleSize = _fluidType(pageWidth, min: 38, max: 68, base: 1400);
    final bodySize = _fluidType(pageWidth, min: 13.5, max: 16.5, base: 1200);
    final ctaTextSize = _fluidType(pageWidth, min: 13, max: 15, base: 1200);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accentAmber.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: AppColors.accentAmber.withValues(alpha: 0.28)),
          ),
          child: Text(
            'Digital Asset Protection Platform',
            style: AppTextStyles.mono(
              size: badgeSize,
              weight: FontWeight.w700,
              color: AppColors.accentAmber,
              letterSpacing: 0.9,
            ),
          ),
        ).animate().fadeIn(delay: 140.ms),
        const SizedBox(height: 18),
        Text(
          'Zero Trust.\nTotal Custody.',
          style: AppTextStyles.display(
            size: compact ? titleSize * 0.88 : titleSize,
            height: 1,
            weight: FontWeight.w900,
            letterSpacing: -1.6,
            color: c.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.06, end: 0),
        const SizedBox(height: 16),
        Text(
          'Enterprise-grade protection for modern media workflows with immutable audit trails, real-time threat intelligence, and secure access orchestration.',
          style: AppTextStyles.body(
            size: bodySize,
            color: c.textSecondary,
            height: 1.6,
          ),
        ).animate().fadeIn(delay: 320.ms),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => context.go('/signup'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentAmber,
                foregroundColor: AppColors.textOnAmber,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              icon: Icon(PhosphorIcons.arrowRight()),
              label: Text(
                'Launch Secure Session',
                style: AppTextStyles.display(
                  size: ctaTextSize,
                  weight: FontWeight.w700,
                  color: AppColors.textOnAmber,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/login'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: c.borderDefault.withValues(alpha: 0.8)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              ),
              icon: Icon(PhosphorIcons.userCircle(),
                  color: c.textSecondary, size: 18),
              label: Text(
                'Sign In To Continue',
                style: AppTextStyles.body(
                  size: ctaTextSize,
                  weight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 420.ms),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SizedBox(
      height: 370,
      child: Stack(
        children: [
          Positioned.fill(
            child: _GlassShell(
              radius: 24,
              padding: EdgeInsets.zero,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      c.bgTertiary.withValues(alpha: c.isDark ? 0.85 : 0.55),
                      c.bgSurface.withValues(alpha: c.isDark ? 0.66 : 0.88),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -18,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.accentAmber.withValues(alpha: 0.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: -20,
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              c.accentBlue.withValues(alpha: 0.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: _MetricCard(
              label: 'Assets Secured',
              value: '2.5M+',
              icon: PhosphorIcons.shieldCheck(),
            ),
          ),
          Positioned(
            top: 124,
            right: 16,
            child: _MetricCard(
              label: 'Response Latency',
              value: '12ms',
              icon: PhosphorIcons.lightning(),
              accent: c.accentBlue,
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: _MetricCard(
              label: 'Threats Neutralized',
              value: '4,821',
              icon: PhosphorIcons.warningCircle(),
              accent: AppColors.accentGreen,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 280.ms).slideX(begin: 0.08, end: 0);
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final PhosphorIconData icon;
  final Color? accent;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pageWidth = MediaQuery.of(context).size.width;
    final valueSize = _fluidType(pageWidth, min: 26, max: 36, base: 1400);

    return Container(
      width: 188,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.bgSecondary.withValues(alpha: c.isDark ? 0.62 : 0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.borderDefault.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: c.isDark ? 0.20 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.accentAmber),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(
                    size: 11,
                    weight: FontWeight.w600,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyles.display(
                size: valueSize,
                weight: FontWeight.w800,
                letterSpacing: -0.8,
                color: accent ?? AppColors.accentAmber,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 260.ms)
        .slideY(begin: 0.04, end: 0, duration: 500.ms);
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final items = <({String label, String value})>[
      (label: 'Active Organizations', value: '142'),
      (label: 'Protected Files', value: '2.5M+'),
      (label: 'Automated Mitigations', value: '4,821'),
      (label: 'Platform Uptime', value: '99.99%'),
    ];

    return _GlassShell(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1200
              ? 4
              : width >= 820
                  ? 2
                  : 1;
          const spacing = 14.0;
          final itemWidth = (width - ((columns - 1) * spacing)) / columns;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: items
                .map(
                  (item) => SizedBox(
                    width: itemWidth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: c.bgSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: c.borderSubtle),
                        boxShadow: c.isDark
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.22),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  blurRadius: 8,
                                  offset: const Offset(-2, -2),
                                ),
                                BoxShadow(
                                  color: const Color(0xFF64748B)
                                      .withValues(alpha: 0.18),
                                  blurRadius: 14,
                                  offset: const Offset(6, 7),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item.value,
                              style: AppTextStyles.display(
                                size: _fluidType(itemWidth,
                                    min: 26, max: 36, base: 360),
                                weight: FontWeight.w800,
                                color: AppColors.accentAmber,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: AppTextStyles.body(
                              size: _fluidType(itemWidth,
                                  min: 12, max: 14, base: 360),
                              weight: FontWeight.w600,
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    ).animate().fadeIn(delay: 480.ms);
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final features = <({String title, String desc, PhosphorIconData icon})>[
      (
        title: 'AI-Powered Detection',
        desc:
            'Detect manipulation signatures and risk patterns across distributed media channels.',
        icon: PhosphorIcons.brain(),
      ),
      (
        title: 'Immutable Audit Trail',
        desc:
            'Preserve chain-of-custody history from first upload to every forensic review.',
        icon: PhosphorIcons.linkSimple(),
      ),
      (
        title: 'Zero-Knowledge Security',
        desc:
            'Restrict data visibility and key usage with hardened identity boundaries.',
        icon: PhosphorIcons.lockKeyOpen(),
      ),
      (
        title: 'Compliance Ready',
        desc:
            'Generate governance-friendly logs and evidence streams for audits.',
        icon: PhosphorIcons.certificate(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enterprise-Grade Protection',
          style: AppTextStyles.display(
            size: 34,
            weight: FontWeight.w800,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width > 1040
                ? 4
                : width > 700
                    ? 2
                    : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: features.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: crossAxisCount == 1 ? 1.8 : 1.14,
              ),
              itemBuilder: (_, i) {
                final item = features[i];
                return _GlassShell(
                  radius: 16,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.accentAmber.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon,
                            color: AppColors.accentAmber, size: 20),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        item.title,
                        style: AppTextStyles.display(
                          size: 17,
                          weight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.desc,
                        style: AppTextStyles.body(
                          size: 13,
                          height: 1.45,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: Duration(milliseconds: 90 * (i + 1))).fadeIn();
              },
            );
          },
        ),
      ],
    );
  }
}

class _CtaBand extends StatelessWidget {
  const _CtaBand();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return _GlassShell(
      radius: 24,
      padding: const EdgeInsets.all(24),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 18,
        spacing: 18,
        children: [
          SizedBox(
            width: 620,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready To Protect Your Media Assets?',
                  style: AppTextStyles.display(
                    size: 32,
                    weight: FontWeight.w800,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your secure workspace and begin monitoring high-risk asset activity in minutes.',
                  style: AppTextStyles.body(size: 15, color: c.textSecondary),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => context.go('/signup'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentAmber,
              foregroundColor: AppColors.textOnAmber,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            icon: Icon(PhosphorIcons.lockSimple()),
            label: Text(
              'Get Started Free',
              style: AppTextStyles.display(
                size: 14,
                weight: FontWeight.w800,
                color: AppColors.textOnAmber,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 580.ms);
  }
}

class _GlassShell extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  const _GlassShell({
    required this.child,
    this.radius = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: c.bgSecondary.withValues(alpha: c.isDark ? 0.46 : 0.72),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: c.borderDefault.withValues(alpha: 0.75)),
            boxShadow: c.isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.24),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.95),
                      blurRadius: 12,
                      offset: const Offset(-2, -2),
                    ),
                    BoxShadow(
                      color: const Color(0xFF64748B).withValues(alpha: 0.14),
                      blurRadius: 22,
                      offset: const Offset(8, 10),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );
  }
}
