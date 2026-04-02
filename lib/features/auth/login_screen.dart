import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/widgets/theme_toggle_button.dart';
import '../../core/widgets/scale_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bgPrimary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 1000;
          final availableHeight = constraints.maxHeight;
          
          return Stack(
            children: [
              // LAYER 1: BASE
              Positioned.fill(child: AnimatedContainer(duration: 300.ms, color: c.bgPrimary)),

              // LAYER 2: CLEAN BACKGROUND
              Positioned.fill(
                child: Container(color: c.bgPrimary),
              ),

              // LAYER 3: CONTENT
              Positioned.fill(
                child: isMobile 
                  ? _MobileView(
                      obscurePassword: _obscurePassword,
                      onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                    )
                  : Row(
                      children: [
                        // LEFT PANEL: 55%
                        Expanded(
                          flex: 55,
                          child: _LeftPanel(availableHeight: availableHeight),
                        ),
                        
                        // DIVIDER
                        AnimatedContainer(
                          duration: 300.ms,
                          width: 1,
                          color: c.borderDefault.withValues(alpha: 0.5),
                        ),

                        // RIGHT PANEL: 45%
                        Expanded(
                          flex: 45,
                          child: _RightPanel(
                            obscurePassword: _obscurePassword,
                            onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                            availableHeight: availableHeight,
                          ),
                        ),
                      ],
                    ),
              ),

              // THEME TOGGLE — Top Right
              const Positioned(
                top: 8,
                right: 8,
                child: ThemeToggleButton(compact: true),
              ),
            ],
          );
        }
      ),
    );
  }
}

class _LeftPanel extends StatelessWidget {
  final double availableHeight;
  const _LeftPanel({required this.availableHeight});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      children: [
        // ZONE A - AMBER HEADER BAR
        Container(
          height: 52,
          color: AppColors.accentAmber,
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CustomPaint(painter: _MiniShieldPainter(coreColor: AppColors.textOnAmber)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "SENTINEL AI",
                    style: AppTextStyles.display(
                      size: 15,
                      weight: FontWeight.w800,
                      color: AppColors.textOnAmber,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox.shrink(),
            ],
          ),
        ).animate().slideY(
          begin: -1,
          end: 0,
          duration: 350.ms,
          curve: Curves.easeOut,
        ),

        // ZONE B - MAIN CONTENT
        Expanded(
          child: Stack(
            children: [
              // BACKGROUND 
              Positioned.fill(
                child: Container(color: c.bgPrimary),
              ),

              // FOREGROUND CONTENT
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(48, 52, 40, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      const SizedBox(height: 52),

                      // HEADLINE BLOCK
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ZERO\nTRUST.",
                            style: AppTextStyles.display(
                              size: availableHeight < 700 ? 56 : 80,
                              weight: FontWeight.w900,
                              color: c.textPrimary,
                              height: 0.9,
                              letterSpacing: -2,
                              shadows: c.isDark ? [
                                Shadow(
                                  color: c.textPrimary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                ),
                              ] : [],
                            ),
                          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.05, end: 0),
                          const SizedBox(height: 8),
                          Text(
                            "TOTAL\nCUSTODY.",
                            style: AppTextStyles.display(
                              size: availableHeight < 700 ? 56 : 80,
                              weight: FontWeight.w900,
                              color: AppColors.accentAmber,
                              height: 0.9,
                              letterSpacing: -2,
                              shadows: c.isDark ? [
                                Shadow(
                                  color: AppColors.accentAmber.withValues(alpha: 0.4),
                                  blurRadius: 30,
                                ),
                              ] : [],
                            ),
                          ).animate(delay: 150.ms).fadeIn(duration: 600.ms).slideX(begin: -0.05, end: 0),
                        ],
                      ),
                      
                      const SizedBox(height: 48),
                      
                      const SizedBox(height: 12),

                      const SizedBox(height: 48),

                      Text(
                        "AI-powered semantic detection and cryptographic\nchain of custody for sports media organizations.",
                          style: AppTextStyles.body(
                            size: 18,
                            weight: FontWeight.w500,
                            color: c.textSecondary,
                            height: 1.6,
                          ),
                      ).animate(delay: 450.ms).fadeIn(),

                      const SizedBox(height: 64),

                      // LIVE METRICS BLOCK
                      const _MetricsDashboard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox.shrink(),
      ],
    );
  }
}

class _RightPanel extends StatelessWidget {
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final double availableHeight;

  const _RightPanel({
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.availableHeight,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AnimatedContainer(
      duration: 300.ms,
      color: c.bgPrimary,
      child: Column(
        children: [
          // ZONE A - HEADER
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: c.bgSecondary,
              border: Border(bottom: BorderSide(color: c.borderDefault, width: 1)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "SESSION ID: SEN-${DateTime.now().millisecond}-ALPHA",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 11,
                    color: c.textMuted,
                    letterSpacing: 1,
                  ),
                ),
                Row(
                  children: [
                    Container(width: 6, height: 6, color: c.accentBlue),
                    const SizedBox(width: 8),
                    Text(
                      "ENC: TLS 1.3  ·  AES-256-GCM",
                      style: AppTextStyles.mono(
                        size: 10,
                        color: c.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ZONE B - FORM
          Expanded(
            child: Stack(
              children: [
                const SizedBox.shrink(),

                // FORM CONTENT
                Positioned.fill(
                  child: Center(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ADMINISTRATOR",
                                style: AppTextStyles.display(
                                  size: 14,
                                  weight: FontWeight.w800,
                                  color: AppColors.accentAmber,
                                  letterSpacing: 3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "ACCESS TERMINAL",
                                style: AppTextStyles.display(
                                  size: 32,
                                  weight: FontWeight.w800,
                                  color: c.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(width: 24, height: 2, color: AppColors.accentAmber),
                                  const SizedBox(width: 8),
                                  Container(width: 8, height: 2, color: c.accentBlue),
                                  const SizedBox(width: 8),
                                  Expanded(child: Container(height: 1, color: c.borderDefault)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Restricted to verified organizational identities",
                                style: AppTextStyles.body(
                                  size: 15,
                                  color: c.textSecondary,
                                  weight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: availableHeight < 600 ? 20 : 36),
                              const _FormLabel(label: "IDENTITY", color: AppColors.accentAmber),
                              const SizedBox(height: 8),
                              const _StyledTextField(hint: "admin@organization.com"),
                              SizedBox(height: availableHeight < 600 ? 12 : 20),
                              const _FormLabel(label: "CREDENTIAL", color: AppColors.accentAmber),
                              const SizedBox(height: 8),
                              _StyledTextField(
                                hint: "••••••••••••",
                                isPassword: true,
                                obscureText: obscurePassword,
                                onToggle: onToggleObscure,
                              ),
                              SizedBox(height: availableHeight < 600 ? 18 : 28),
                              _AuthButton(),
                              const SizedBox(height: 16),
                              const _SecurityStatusBar(),
                              const SizedBox(height: 20),
                              Text(
                                "Unauthorized access is a violation of organizational policy and applicable law. All sessions are logged.",
                                style: AppTextStyles.body(
                                  size: 13,
                                  color: c.textMuted,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 150.ms, duration: 500.ms).slideX(begin: 0.03, end: 0, duration: 500.ms),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _MobileView extends StatelessWidget {
  final bool obscurePassword;
  final VoidCallback onToggleObscure;

  const _MobileView({
    required this.obscurePassword,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      color: c.bgSecondary,
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SENTINEL AI",
                    style: AppTextStyles.display(
                      size: 16,
                      weight: FontWeight.w800,
                      color: AppColors.accentAmber,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "ADMIN TERMINAL",
                    style: AppTextStyles.display(
                      size: 28,
                      weight: FontWeight.w800,
                      color: c.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const _FormLabel(label: "IDENTITY", color: AppColors.accentAmber),
                  const SizedBox(height: 8),
                  const _StyledTextField(hint: "admin@organization.com"),
                  const SizedBox(height: 20),
                  const _FormLabel(label: "CREDENTIAL", color: AppColors.accentAmber),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    hint: "••••••••••••",
                    isPassword: true,
                    obscureText: obscurePassword,
                    onToggle: onToggleObscure,
                  ),
                  const SizedBox(height: 32),
                  _AuthButton(),
                  const SizedBox(height: 24),
                  const _SecurityStatusBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniShieldPainter extends CustomPainter {
  final Color coreColor;
  const _MiniShieldPainter({required this.coreColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0A0C10)
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    // Draw Hexagon
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

    // Inner detail
    final detailPaint = Paint()
      ..color = coreColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    
    canvas.drawCircle(Offset(centerX, centerY), radius * 0.4, detailPaint);
    
    final corePaint = Paint()
      ..color = coreColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), radius * 0.15, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



class _MetricsDashboard extends StatelessWidget {
  const _MetricsDashboard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedContainer(
      duration: 300.ms,
      decoration: BoxDecoration(
        color: c.bgSecondary,
        border: Border.all(color: c.borderDefault, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Container(height: 3, color: AppColors.accentAmber)),
              Expanded(child: Container(height: 3, color: c.accentBlue)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "LIVE THREAT DETECTION METRICS",
                          style: AppTextStyles.display(
                            size: 13,
                            weight: FontWeight.w800,
                            color: c.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                        Row(
                          children: [
                            const _PulsingStatusDot(),
                            const SizedBox(width: 8),
                            Text(
                              "SYSTEM ACTIVE",
                              style: AppTextStyles.mono(
                                size: 12,
                                weight: FontWeight.w700,
                                color: AppColors.accentGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Icon(PhosphorIcons.pulse(), color: c.accentBlue, size: 24),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Expanded(child: _LiveStat("THREATS NEUTRALIZED", "4,821", AppColors.accentAmber)),
                    Container(width: 1, height: 40, color: c.borderDefault.withValues(alpha: 0.5)),
                    Expanded(child: _LiveStat("ACTIVE SESSIONS", "142", c.accentBlue)),
                    Container(width: 1, height: 40, color: c.borderDefault.withValues(alpha: 0.5)),
                    const Expanded(child: _LiveStat("LATENCY", "12ms", AppColors.accentGreen)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveStat extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  const _LiveStat(this.label, this.value, this.accent);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.mono(
            size: 12,
            weight: FontWeight.w600,
            color: c.textMuted,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.display(
            size: 28,
            weight: FontWeight.w800,
            color: accent,
          ),
        ),
      ],
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _FormLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 4, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.display(
            size: 14,
            weight: FontWeight.w700,
            color: color,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggle;

  const _StyledTextField({
    required this.hint,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.bgSurface,
        border: const Border(left: BorderSide(color: AppColors.accentAmber, width: 3)),
      ),
      child: TextField(
        obscureText: obscureText,
        style: AppTextStyles.body(color: c.textPrimary, size: 15),
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(obscureText ? PhosphorIcons.eyeClosed() : PhosphorIcons.eye(), size: 18),
                color: c.textMuted,
                onPressed: onToggle,
              )
            : null,
        ),
      ),
    );
  }
}

class _AuthButton extends StatefulWidget {
  const _AuthButton();

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: ScaleButton(
        onTap: () {
          AppRouter.isAuthenticated = true;
          context.go('/dashboard');
        },
        child: AnimatedContainer(
          duration: 200.ms,
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _isHovering ? AppColors.accentAmber.withValues(alpha: 0.9) : AppColors.accentAmber,
            boxShadow: _isHovering ? [
              BoxShadow(color: AppColors.accentAmber.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 4)),
            ] : [],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(PhosphorIcons.shieldCheck(), size: 60, color: Colors.black.withValues(alpha: 0.05)),
              ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "AUTHENTICATE SYSTEM ACCESS",
                      style: AppTextStyles.display(
                        size: 14,
                        weight: FontWeight.w800,
                        color: AppColors.textOnAmber,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(PhosphorIcons.arrowRight(), color: AppColors.textOnAmber, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityStatusBar extends StatelessWidget {
  const _SecurityStatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const _SimpleStatusDot(color: AppColors.accentGreen, size: 6),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "SECURE CONNECTION ESTABLISHED",
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.display(
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.accentGreen,
                letterSpacing: 1,
              ),
            ),
          ),
          Icon(PhosphorIcons.lockKey(), size: 14, color: AppColors.accentGreen),
        ],
      ),
    );
  }
}



class _PulsingStatusDot extends StatefulWidget {
  const _PulsingStatusDot();
  @override
  State<_PulsingStatusDot> createState() => _PulsingStatusDotState();
}

class _PulsingStatusDotState extends State<_PulsingStatusDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 1.seconds)..repeat(reverse: true);
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Container(
        width: 8, height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accentGreen,
          boxShadow: [
            BoxShadow(color: AppColors.accentGreen.withValues(alpha: 0.4 * _ctrl.value), blurRadius: 8, spreadRadius: 2),
          ],
        ),
      ),
    );
  }
}

class _SimpleStatusDot extends StatelessWidget {
  final Color color;
  final double size;
  const _SimpleStatusDot({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
